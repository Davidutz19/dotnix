{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.heroic ];
      davidutz.persist.directories = [
        ".config/heroic"
        ".local/state/Heroic"
      ];
    };
}
