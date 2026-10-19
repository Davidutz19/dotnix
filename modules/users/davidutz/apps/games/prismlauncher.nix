# Minecraft launcher.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.prismlauncher ];
      davidutz.persist.directories = [ ".local/share/PrismLauncher" ];
    };
}
