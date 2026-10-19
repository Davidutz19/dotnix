{
  flake.homeModules.davidutzDesktop = {
    programs.firefox.enable = true;
    davidutz.persist.directories = [ ".config/mozilla" ];
  };
}
