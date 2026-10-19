# Desktop services that aren't tied to the compositor: file manager backends,
# Flatpak (Sober), Sunshine streaming, and running prebuilt binaries.
{ inputs, ... }:
{
  flake.nixosModules.desktop = {
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

    services.gvfs.enable = true; # MTP, trash, network shares in Nautilus
    services.tumbler.enable = true; # thumbnails
    services.udisks2.enable = true;

    services.flatpak = {
      enable = true;
      # nix-flatpak adds Flathub and installs these on switch, then updates them weekly.
      packages = [ "org.vinegarhq.Sober" ]; # Roblox
      update.auto.enable = true;
    };

    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true; # KMS capture
      openFirewall = true;
    };

    hm.davidutz.persist.directories = [
      # Data of Flatpak apps (Sober), and apps installed with `flatpak --user`.
      ".var/app"
      ".local/share/flatpak"
      # Paired clients and Sunshine's own settings.
      ".config/sunshine"
    ];

    # Prebuilt binaries (npm/bun native modules, Unreal Engine, downloaded CLIs)
    # expect /lib64/ld-linux-x86-64.so.2; nix-ld provides it.
    programs.nix-ld.enable = true;
  };
}
