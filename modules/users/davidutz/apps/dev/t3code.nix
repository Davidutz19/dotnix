# Control surface for coding agents, local or on another machine. Machines that run
# the agents themselves also get the agents profile (agents/). The nixpkgs package
# puts codex, gh and git on T3 Code's PATH.
{
  flake.homeModules.davidutzDesktop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      c = lib.mapAttrs (_: hex: "#${hex}") config.davidutz.theme.colors;
      ui = lib.mapAttrs (_: hex: "#${hex}") config.davidutz.theme.ui;

      # A theme in T3 Code's "seeded" form: it derives every surface from `canvas`
      # and `accent` with its own theme generator, then applies `colors` on top. The
      # generator tints surfaces with the accent, so the surfaces are pinned to the
      # island's neutral levels: background for the window, surface for cards and
      # fields, raised and highlight for controls and selection. The accent stays on
      # what is active, as on the island.
      # Role names: THEME_COLOR_ROLES in T3 Code's packages/shared/src/themePalettes.ts.
      theme = pkgs.writeText "t3code-theme.json" (
        builtins.toJSON {
          name = "Catppuccin Mocha (dotnix)";
          appearance = "dark";
          canvas = ui.background;
          accent = ui.accent;
          colors = {
            accentForeground = ui.onAccent;
            focus = ui.accent;
            text = ui.foreground;
            textMuted = c.subtext0;
            border = ui.raised;

            chrome = ui.background;
            toolbar = ui.background;
            toolbarForeground = ui.foreground;
            toolbarBorder = ui.raised;
            toolbarControl = ui.surface;
            toolbarControlForeground = ui.foreground;
            toolbarControlHover = ui.raised;
            surface = ui.surface;
            surfaceRaised = ui.raised;
            surfaceOverlay = ui.surface;
            input = ui.surface;
            secondary = ui.raised;
            secondaryForeground = ui.foreground;
            muted = ui.surface;
            mutedForeground = c.subtext0;
            messageSurface = ui.surface;
            messageForeground = ui.foreground;

            sidebar = ui.background;
            sidebarForeground = ui.foreground;
            sidebarMutedForeground = c.subtext0;
            sidebarBorder = ui.raised;
            sidebarControlSurface = ui.surface;
            sidebarRowHover = ui.surface;
            sidebarRowActive = ui.raised;
            sidebarRowSelected = ui.highlight;
            codeBackground = ui.surface;
            codeForeground = ui.foreground;
            terminalBackground = ui.background;
            terminalForeground = ui.foreground;
            terminalCursor = c.rosewater;
            terminalSelection = ui.highlight;
            error = ui.danger;
            warning = c.yellow;
            update = ui.success;
          };
        }
      );
      themeFile = "${config.home.homeDirectory}/.t3/userdata/themes/dotnix.json";
    in
    {
      home.packages = [ pkgs.t3code ];

      # T3 Code watches ~/.t3/userdata/themes and refuses symlinked files there, so
      # `t3 theme set` copies the theme in and makes it the default. It only runs when
      # the palette changed: picking another theme in the app survives a rebuild.
      home.activation.t3codeTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if ! cmp -s ${theme} ${lib.escapeShellArg themeFile}; then
          run ${pkgs.t3code}/bin/t3 theme set --id dotnix ${theme}
        fi
      '';

      # T3 Code writes this desktop file into ~/.local/share/applications itself,
      # but can't register it: home-manager owns mimeapps.list.
      xdg.mimeApps.defaultApplications."x-scheme-handler/t3code" = "com.t3tools.T3Code.desktop";

      davidutz.persist.directories = [
        ".t3" # threads, worktrees, attachments and the published theme
        ".config/T3 Code (Alpha)"
        ".codex"
      ];
    };
}
