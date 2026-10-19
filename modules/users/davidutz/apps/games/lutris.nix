# Steam itself is a NixOS module (system/gaming.nix).
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.lutris ];
      davidutz.persist.directories = [
        ".local/share/lutris"
        # Steam runtimes that umu-launcher downloads for Proton games.
        ".local/share/umu"
      ];
    };
}
