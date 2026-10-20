# Ghostty, with its theme built from the desktop palette (theme.nix).
{
  flake.homeModules.davidutzDesktop =
    { config, lib, ... }:
    let
      c = config.davidutz.theme.colors;
      ui = config.davidutz.theme.ui;

      # ANSI colours 0-15, in Catppuccin's order for terminals.
      ansi = [
        "surface1"
        "red"
        "green"
        "yellow"
        "blue"
        "pink"
        "teal"
        "subtext0"
        "surface2"
        "red"
        "green"
        "yellow"
        "blue"
        "pink"
        "teal"
        "subtext1"
      ];
    in
    {
      programs.ghostty = {
        enable = true;
        settings = {
          theme = "catppuccin-mocha";
          # Stay running after the last window closes, so the next SUPER + RETURN
          # gets a window from the running Ghostty instead of starting a new one.
          quit-after-last-window-closed = false;
        };
        themes.catppuccin-mocha = {
          palette = lib.imap0 (i: name: "${toString i}=#${c.${name}}") ansi;
          background = ui.background;
          foreground = ui.foreground;
          cursor-color = c.rosewater;
          cursor-text = ui.background;
          selection-background = ui.highlight;
          selection-foreground = ui.foreground;
          split-divider-color = ui.raised;
        };
      };

      # Ghostty keeps running in the background (`programs.ghostty.systemd`, on by
      # default) and SUPER + RETURN asks it for a window: about 0.1 s to a running
      # shell, against 0.7 s for a new process. The module installs the service but
      # doesn't start it; this link starts it with the session, like
      # `systemctl --user enable`.
      xdg.configFile."systemd/user/graphical-session.target.wants/app-com.mitchellh.ghostty.service".source =
        "${config.programs.ghostty.package}/share/systemd/user/app-com.mitchellh.ghostty.service";

      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("ghostty +new-window"))
      '';
    };
}
