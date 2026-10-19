# PeaZip is the GUI archive manager. libarchive provides bsdtar, which Mochi needs.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.peazip
        pkgs.libarchive
      ];
    };
}
