# Network configuration for one-piece
# Host-specific: hostname, VM bridge
_:

{
  flake.modules.nixos.one-piece-network = _: {
    # Guests sit on libvirt's default NAT network. Features that need to reach
    # a VM scope themselves to this interface rather than to an address.
    host.vmBridge = "virbr0";

    # WiFi needs no declaration here: the card in this laptop is a Realtek
    # RTL8852BE (WiFi 6, rtw89_8852be), which the NetworkManager defaults drive
    # as-is - wpa_supplicant as backend, iwd off. Both were once pinned in this
    # module to match those same defaults; asserting a default only implies the
    # host needs something special, so they are gone.
    networking.hostName = "one-piece";
  };
}
