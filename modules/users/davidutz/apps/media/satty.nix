# Satty, the screenshot annotator. Mochi's capture preview opens it from its Edit button.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.satty ];

      xdg.mimeApps.enable = true;
      xdg.mimeApps.defaultApplications = {
        "image/png" = "satty.desktop";
        "image/jpeg" = "satty.desktop";
        "image/webp" = "satty.desktop";
        "image/bmp" = "satty.desktop";
      };

      wayland.windowManager.hyprland.extraConfig = ''
        hl.window_rule({ name = "satty", match = { class = "com.gabm.satty" }, float = true })
      '';
    };
}
