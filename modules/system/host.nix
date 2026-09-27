# Machine facts, declared by the host and consumed by feature modules.
#
# The dendritic split cuts both ways. A feature must not name a GPU vendor or a
# monitor; a host must not name an app. This module is the seam between them:
# hosts describe what the machine *is*, features decide what to do about it.
#
# Nothing here configures anything. Adding a fact means adding an option here
# and reading it as the default of some feature's own option, so the feature
# stays overridable and the host stays app-agnostic.
_:

{
  flake.modules.nixos.host =
    { lib, ... }:
    {
      options.host = {
        formFactor = lib.mkOption {
          type = lib.types.enum [
            "desktop"
            "laptop"
          ];
          default = "desktop";
          description = ''
            Whether this machine runs on a battery and has a lid. Features use
            it to decide about battery readouts, on-battery idle timeouts and
            lid-switch handling.
          '';
        };

        displays = {
          internal = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "eDP-1";
            description = ''
              Connector name of the built-in panel, or null on a machine with
              no built-in display.
            '';
          };

          internalWidth = lib.mkOption {
            type = lib.types.ints.positive;
            default = 1920;
            description = ''
              Pixel width of the built-in panel. Needed as a fallback because a
              disabled panel reports no geometry, so anything laying out around
              it has nothing to measure.
            '';
          };

          external = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            example = [
              "DELL U2424HE"
              "DELL SE2422H"
            ];
            description = ''
              External monitors normally attached to this machine, ordered left
              to right as they physically sit. Identified by model string
              rather than connector, so a display keeps its place whichever
              port it lands on.
            '';
          };

          disableInternalAt = lib.mkOption {
            type = lib.types.ints.positive;
            default = 2;
            description = ''
              How many of {option}`host.displays.external` must be connected
              before the built-in panel is switched off.
            '';
          };
        };

        input = {
          internalKeyboard = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
            description = ''
              Device node of the keyboard built into this machine, or null on a
              machine that only ever has external keyboards. A by-path node is
              the stable choice; by-id enumerates differently across boots.
            '';
          };

          ignoredKeyboards = lib.mkOption {
            type = lib.types.listOf (
              lib.types.submodule {
                options = {
                  vendor = lib.mkOption {
                    type = lib.types.str;
                    example = "046d";
                    description = "USB idVendor, lowercase hex, no 0x prefix.";
                  };
                  product = lib.mkOption {
                    type = lib.types.str;
                    example = "c548";
                    description = "USB idProduct, lowercase hex, no 0x prefix.";
                  };
                };
              }
            );
            default = [ ];
            description = ''
              USB devices that enumerate as keyboards but are not ones anybody
              types on - unifying receivers, KVM dongles, some mice. Anything
              that reacts to an external keyboard being plugged in should skip
              these, or it will react to a mouse dongle.
            '';
          };
        };

        gpu.offloadCommand = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "nvidia-offload";
          description = ''
            Command that runs its arguments on this machine's discrete GPU, on
            hybrid-graphics hardware. Null on single-GPU machines. Apps that
            benefit from the discrete GPU use it to install a second launcher.
          '';
        };

        vmBridge = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = "virbr0";
          example = "br0";
          description = ''
            Network bridge that guest VMs sit on. libvirt's default NAT network
            calls it virbr0. Null on machines that run no VMs.
          '';
        };
      };
    };
}
