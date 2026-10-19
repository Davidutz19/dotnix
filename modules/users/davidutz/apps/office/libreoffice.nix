{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.libreoffice ];
      davidutz.persist.directories = [ ".config/libreoffice" ];
    };
}
