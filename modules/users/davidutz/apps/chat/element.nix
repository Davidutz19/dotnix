# Matrix client.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.element-desktop ];
      davidutz.persist.directories = [ ".config/Element" ];
    };
}
