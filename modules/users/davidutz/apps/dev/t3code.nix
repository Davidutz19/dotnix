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

      # A theme in T3 Code's "seeded" form: it derives every surface from `canvas`
      # and `accent` with its own theme generator, then applies `colors` on top.
      # Role names: THEME_COLOR_ROLES in T3 Code's packages/shared/src/themePalettes.ts.
      theme = pkgs.writeText "t3code-theme.json" (
        builtins.toJSON {
          name = "Catppuccin Mocha (dotnix)";
          appearance = "dark";
          canvas = c.base;
          accent = c.lavender;
          colors = {
            accentForeground = c.crust;
            focus = c.lavender;
            text = c.text;
            textMuted = c.subtext0;
            border = c.surface0;
            sidebar = c.mantle;
            sidebarForeground = c.text;
            sidebarMutedForeground = c.subtext0;
            codeBackground = c.mantle;
            codeForeground = c.text;
            terminalBackground = c.base;
            terminalForeground = c.text;
            terminalCursor = c.rosewater;
            terminalSelection = c.surface1;
            error = c.red;
            warning = c.yellow;
            update = c.green;
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
