# Needs its port open on the host to receive (TODO.md, Apps).
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.localsend ];
    };
}
