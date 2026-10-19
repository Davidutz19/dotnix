{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nautilus ];

      # VSCodium's desktop file also claims inode/directory, so pin Nautilus.
      xdg.mimeApps.enable = true;
      xdg.mimeApps.defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";

      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd("nautilus"))
      '';
    };
}
