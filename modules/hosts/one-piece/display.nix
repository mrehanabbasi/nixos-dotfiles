# Displays and form factor for one-piece
# Host-specific: the built-in panel, the monitors on this desk, and the fact
# that this machine is a laptop. Facts only - which app reacts to them, and
# how, is the feature's business (see modules/system/host.nix).
_:

{
  flake.modules.nixos.one-piece-display = _: {
    host = {
      formFactor = "laptop";

      displays = {
        internal = "eDP-1";
        internalWidth = 1920;

        # Left to right as they sit on the desk. Matched on the monitor
        # description, so either one can move ports freely.
        external = [
          "DELL U2424HE"
          "DELL SE2422H"
        ];

        # With both up the laptop panel is redundant; with one, it stays on as
        # the left-hand screen.
        disableInternalAt = 2;
      };
    };
  };
}
