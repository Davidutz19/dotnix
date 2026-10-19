# Minecraft PvP client.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.lunar-client ];
      davidutz.persist.directories = [
        ".lunarclient"
        ".config/lunarclient"
        ".minecraft"
      ];
    };
}
