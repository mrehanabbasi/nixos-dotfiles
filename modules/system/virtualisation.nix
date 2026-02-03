# Virtualisation and container configuration
_:

{
  flake.modules.nixos.virtualisation =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      # ════════════════════════════════════════════════════════════════════
      # Container support
      # ════════════════════════════════════════════════════════════════════
      virtualisation = {
        containers.enable = true;
        podman = {
          enable = true;

          # Create a `docker` alias for podman, to use it as a drop-in replacement
          dockerCompat = true;

          # Required for containers under podman-compose to be able to talk to each other
          defaultNetwork.settings.dns_enabled = true;

          dockerSocket.enable = true;
        };
        oci-containers.backend = "podman";

        # ════════════════════════════════════════════════════════════════════
        # QEMU/KVM support for Windows VMs
        # ════════════════════════════════════════════════════════════════════
        libvirtd = {
          enable = true;

          # QEMU configuration
          qemu = {
            package = pkgs.qemu_kvm; # KVM-optimized QEMU
            runAsRoot = false; # Run as user for better security

            # Enable TPM emulation (required for Windows 11)
            swtpm.enable = true;
          };

          # VM lifecycle management
          onBoot = "ignore"; # Don't auto-start VMs on boot
          onShutdown = "shutdown"; # Gracefully shutdown VMs
        };

        # Enable SPICE USB redirection (for better USB device passthrough)
        spiceUSBRedirection.enable = true;
      };

      # Enable dconf (required by virt-manager)
      programs.dconf.enable = true;

      # Install virtualization tools
      environment.systemPackages = [
        pkgs.virt-manager # GUI for managing VMs
        pkgs.virt-viewer # Lightweight VM viewer
        pkgs.spice # Remote display protocol
        pkgs.spice-gtk # SPICE client GTK
        pkgs.spice-protocol # SPICE protocol headers
        pkgs.virtio-win # Windows VirtIO drivers ISO
        pkgs.win-spice # Windows SPICE guest tools
        pkgs.qemu_kvm # Expose qemu-* commands to users (also used by libvirtd)
        pkgs.OVMF # UEFI firmware for VMs
        pkgs.swtpm # TPM emulator
      ];

      # Note: libvirtd automatically configures firewall rules for default network (virbr0)
    };
}
