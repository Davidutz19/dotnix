# One colour palette for everything (Catppuccin Mocha), plus GTK, icons and Qt.
#
# Starship, Hyprland, ghostty, Mochi and GTK read their colours from
# `davidutz.theme.colors`, so switching the palette here switches all of them.
# The palette is in the base profile, so the terminal setup has it without a desktop.
{
  flake.homeModules.davidutz =
    { lib, ... }:
    {
      options.davidutz.theme.colors = lib.mkOption {
        type = with lib.types; attrsOf str;
        description = "Palette as hex RGB without `#`, keyed by Catppuccin colour name.";
        default = {
          rosewater = "f5e0dc";
          flamingo = "f2cdcd";
          pink = "f5c2e7";
          mauve = "cba6f7";
          red = "f38ba8";
          maroon = "eba0ac";
          peach = "fab387";
          yellow = "f9e2af";
          green = "a6e3a1";
          teal = "94e2d5";
          sky = "89dceb";
          sapphire = "74c7ec";
          blue = "89b4fa";
          lavender = "b4befe";
          text = "cdd6f4";
          subtext1 = "bac2de";
          subtext0 = "a6adc8";
          overlay2 = "9399b2";
          overlay1 = "7f849c";
          overlay0 = "6c7086";
          surface2 = "585b70";
          surface1 = "45475a";
          surface0 = "313244";
          base = "1e1e2e";
          mantle = "181825";
          crust = "11111b";
        };
      };
    };

  flake.homeModules.davidutzDesktop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      c = config.davidutz.theme.colors;

      # libadwaita's named colours, from the palette. GTK4 apps (libadwaita) and GTK3
      # apps (adw-gtk3) both draw with these names, so one table recolours both.
      # https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/css-variables.html
      named = {
        accent_color = c.lavender;
        accent_bg_color = c.lavender;
        accent_fg_color = c.crust;
        destructive_color = c.red;
        destructive_bg_color = c.red;
        destructive_fg_color = c.crust;
        success_color = c.green;
        success_bg_color = c.green;
        success_fg_color = c.crust;
        warning_color = c.yellow;
        warning_bg_color = c.yellow;
        warning_fg_color = c.crust;
        error_color = c.red;
        error_bg_color = c.red;
        error_fg_color = c.crust;
        window_bg_color = c.base;
        window_fg_color = c.text;
        view_bg_color = c.base;
        view_fg_color = c.text;
        headerbar_bg_color = c.base;
        headerbar_fg_color = c.text;
        headerbar_backdrop_color = c.base;
        sidebar_bg_color = c.mantle;
        sidebar_fg_color = c.text;
        sidebar_backdrop_color = c.mantle;
        secondary_sidebar_bg_color = c.mantle;
        secondary_sidebar_fg_color = c.text;
        card_bg_color = c.surface0;
        card_fg_color = c.text;
        dialog_bg_color = c.mantle;
        dialog_fg_color = c.text;
        popover_bg_color = c.mantle;
        popover_fg_color = c.text;
        thumbnail_bg_color = c.surface0;
        thumbnail_fg_color = c.text;
      };
      # GTK4: CSS variables (libadwaita 1.6+). GTK3: @define-color.
      gtk4Css = ":root {\n${
        lib.concatStrings (
          lib.mapAttrsToList (n: v: "  --${lib.replaceStrings [ "_" ] [ "-" ] n}: #${v};\n") named
        )
      }}\n";
      gtk3Css = lib.concatStrings (lib.mapAttrsToList (n: v: "@define-color ${n} #${v};\n") named);
    in
    {
      # The light variant is the white cursor, which stays visible on the dark palette.
      # `gtk.enable` fills in `gtk.cursorTheme`. Hyprland reads the same name and size
      # for its session env vars, see desktop/hyprland/hyprland.nix.
      home.pointerCursor = {
        enable = true;
        name = "phinger-cursors-light";
        package = pkgs.phinger-cursors;
        size = 32;
        gtk.enable = true;
      };

      # colorScheme sets org.gnome.desktop.interface color-scheme = prefer-dark, which
      # the GTK portal hands to libadwaita, Firefox/Zen, Chromium and Electron apps.
      gtk = {
        enable = true;
        colorScheme = "dark";
        # GTK3 apps ignore color-scheme and need a dark theme. GTK4 has no theme,
        # only libadwaita's colours, which gtk.css overrides with the palette.
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        gtk3.extraCss = gtk3Css;
        gtk4.theme = null;
        gtk4.extraCss = gtk4Css;
        # Papirus with its folders in the palette's lavender.
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.catppuccin-papirus-folders.override {
            flavor = "mocha";
            accent = "lavender";
          };
        };
      };

      # GTK settings GUI.
      home.packages = [ pkgs.nwg-look ];
      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("SUPER + comma", hl.dsp.exec_cmd("nwg-look"))
      '';

      qt = {
        enable = true;
        platformTheme.name = "adwaita";
        style.name = "adwaita-dark";
      };
    };
}
