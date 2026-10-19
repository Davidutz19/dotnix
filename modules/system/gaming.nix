# Steam and the parts of cachyos-gaming-meta that need system support.
# Launchers without system needs (Lutris, Heroic, Prism, Lunar) are in users/davidutz/apps/games/.
{ inputs, ... }:
{
  flake.nixosModules.gaming = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ]; # replaces protonup-qt
    };
    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    # League of Legends through Darling (darling-lol). The package builds Darling
    # rootless in ~/.local/share/darling-lol on first launch (`darling-lol`), so
    # nothing goes to /usr/local or needs setuid. The rootless namespaces need
    # subordinate UID/GID ranges.
    environment.systemPackages = [
      inputs.darling-lol.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    users.users.davidutz.autoSubUidGidRange = true;

    # The Steam library and login, and the Darling build (about 9 GB).
    hm.davidutz.persist.directories = [
      ".steam"
      ".local/share/Steam"
      ".local/share/darling-lol"
    ];
  };
}
