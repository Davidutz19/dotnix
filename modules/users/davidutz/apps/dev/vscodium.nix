{
  flake.homeModules.davidutzDesktop =
    { lib, ... }:
    {
      programs.vscodium.enable = true;
      # Settings and state, and the extensions installed from the marketplace.
      davidutz.persist.directories = [
        ".config/VSCodium"
        ".vscode-oss"
      ];

      # Zen's setAsDefaultBrowser also claims these. mkBefore puts VSCodium first.
      xdg.mimeApps.defaultApplications = lib.genAttrs [ "text/plain" "application/json" ] (
        _: lib.mkBefore [ "codium.desktop" ]
      );

      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("codium"))
      '';
    };
}
