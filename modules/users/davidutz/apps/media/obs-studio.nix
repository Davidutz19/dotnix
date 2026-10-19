{
  flake.homeModules.davidutzDesktop = {
    programs.obs-studio.enable = true;
    davidutz.persist.directories = [ ".config/obs-studio" ];
  };
}
