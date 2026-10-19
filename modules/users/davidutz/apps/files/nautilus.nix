# Nautilus. Its settings are GSettings: change one in the app, find its key with
# `dconf watch /`, and pin it in `dconf.settings` below.
{
  flake.homeModules.davidutzDesktop =
    { config, pkgs, ... }:
    let
      home = config.home.homeDirectory;
    in
    {
      home.packages = [ pkgs.nautilus ];

      # VSCodium's desktop file also claims inode/directory, so pin Nautilus.
      xdg.mimeApps.enable = true;
      xdg.mimeApps.defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";

      # The sidebar lists the XDG folders: Documents, Downloads, Pictures and Videos by
      # default. The ones set to null point at the home itself, so they aren't listed.
      xdg.userDirs = {
        enable = true;
        desktop = null;
        music = null;
        publicShare = null;
        templates = null;
        projects = null;
      };

      # Sidebar bookmarks below the XDG folders, also used by GTK file pickers.
      gtk.gtk3.bookmarks = [
        "file://${home}/personal"
        "file://${home}/work"
        "file://${home}/Games"
        "file://${home}/personal/dotnix dotnix"
      ];

      dconf.settings = {
        "org/gnome/nautilus/preferences" = {
          default-folder-viewer = "icon-view";
          show-delete-permanently = true;
          show-create-link = true;
        };
        # Shared by Nautilus and the GTK4 file picker.
        "org/gtk/gtk4/settings/file-chooser" = {
          sort-directories-first = true;
        };
      };

      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd("nautilus"))
      '';
    };
}
