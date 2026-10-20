# One colour scheme for everything: Catppuccin Mocha, laid out like Mochi's island.
#
# `davidutz.theme.colors` is the palette and `davidutz.theme.roles` says what each
# colour is for (background, accent, ...), with the choices of Mochi's Catppuccin
# preset: a crust background and a mauve accent. Mochi, Stylix's base16 scheme (GTK,
# Qt, Zen, Discord, Spotify, bat, tmux, ...), Hyprland, Ghostty, T3 Code, Stylus and
# the boot menu all read the roles, so changing one here changes it everywhere.
# The palette is in the base profile, so the terminal setup has it without a desktop.
{ inputs, ... }:
{
  flake.homeModules.davidutz =
    { config, lib, ... }:
    let
      cfg = config.davidutz.theme;
    in
    {
      # What each palette colour is for, as Mochi's theme names them. Every app
      # reads these, so the island and the windows share a background and an
      # accent. Values are names from `colors`.
      options.davidutz.theme.roles = lib.mkOption {
        type = with lib.types; attrsOf str;
        default = {
          background = "crust"; # windows, the island, the terminal
          surface = "base"; # cards, sidebars, code blocks
          raised = "surface0"; # buttons, borders, dividers
          highlight = "surface1"; # hovered and selected things
          foreground = "text";
          muted = "overlay1";
          accent = "mauve"; # what is active or important
          onAccent = "crust"; # text on the accent
          danger = "red";
          success = "green";
        };
      };
      options.davidutz.theme.ui = lib.mkOption {
        type = with lib.types; attrsOf str;
        readOnly = true;
        default = lib.mapAttrs (_: name: cfg.colors.${name}) cfg.roles;
        description = "The roles resolved to hex RGB without `#`.";
      };

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

  # The boot menu (Limine, system/boot.nix), in the same palette. Does nothing on
  # hosts that boot with something else.
  flake.nixosModules.davidutz =
    { config, ... }:
    let
      c = config.hm.davidutz.theme.colors;
      ui = config.hm.davidutz.theme.ui;
    in
    {
      boot.loader.limine.style = {
        wallpapers = [ ./desktop/wallpapers/images/seaside-sunset.jpg ];
        wallpaperStyle = "stretched";
        backdrop = ui.background;
        interface = {
          branding = config.networking.hostName;
          brandingColor = ui.accent;
          helpColor = ui.muted;
        };
        graphicalTerminal = {
          # Catppuccin's terminal order: black, red, green, brown, blue, magenta, cyan, gray.
          palette = "${c.surface1};${c.red};${c.green};${c.yellow};${c.blue};${c.pink};${c.teal};${c.subtext0}";
          brightPalette = "${c.surface2};${c.red};${c.green};${c.yellow};${c.blue};${c.pink};${c.teal};${c.subtext1}";
          foreground = ui.foreground;
          background = "33${ui.background}"; # TTRRGGBB, TT is transparency: 20% over the wallpaper
          brightForeground = ui.accent;
          brightBackground = ui.raised;
        };
      };
    };

  flake.homeModules.davidutzDesktop =
    { config, pkgs, ... }:
    let
      c = config.davidutz.theme.colors;
      inherit (config.davidutz.theme) roles ui;
    in
    {
      imports = [ inputs.stylix.homeModules.stylix ];

      # Stylix themes the apps enabled in `targets` below from the same palette, and
      # sets the cursor, icons and fonts. Other apps it supports: `ls` the modules/
      # folder of the stylix input, then add `<name>.enable = true`.
      stylix = {
        enable = true;
        polarity = "dark";
        # Its overlays (NixOS logo, GtkSourceView) would change nixpkgs, which the
        # home-manager NixOS module forbids with useGlobalPkgs.
        overlays.enable = false;
        # Catppuccin's base16 mapping, with the backgrounds of the roles: base00 is the
        # window background, base01 the sidebars and panels, base02 and base03 the
        # selections. base0D stays blue: it is the syntax colour of functions, and the
        # accent is set per app instead (GTK below).
        base16Scheme = with c; {
          scheme = "Catppuccin Mocha (dotnix)";
          author = "Catppuccin";
          base00 = ui.background;
          base01 = ui.surface;
          base02 = ui.raised;
          base03 = ui.highlight;
          base04 = surface2;
          base05 = ui.foreground;
          base06 = rosewater;
          base07 = lavender;
          base08 = red;
          base09 = peach;
          base0A = yellow;
          base0B = green;
          base0C = teal;
          base0D = blue;
          base0E = mauve;
          base0F = flamingo;
        };

        # The light variant is the white cursor, which stays visible on the dark
        # palette. Hyprland reads its name and size from home.pointerCursor
        # (desktop/hyprland/hyprland.nix).
        cursor = {
          name = "phinger-cursors-light";
          package = pkgs.phinger-cursors;
          size = 32;
        };

        # Papirus with its folders in the accent (a Catppuccin colour name).
        icons = {
          enable = true;
          package = pkgs.catppuccin-papirus-folders.override {
            flavor = "mocha";
            accent = roles.accent;
          };
          dark = "Papirus-Dark";
          light = "Papirus-Light";
        };

        # The packages are installed system-wide (system/hyprland.nix).
        fonts = {
          monospace = {
            name = "JetBrainsMono Nerd Font";
            package = pkgs.nerd-fonts.jetbrains-mono;
          };
          sansSerif = {
            name = "Noto Sans";
            package = pkgs.noto-fonts;
          };
          serif = {
            name = "Noto Serif";
            package = pkgs.noto-fonts;
          };
          emoji = {
            name = "Noto Color Emoji";
            package = pkgs.noto-fonts-color-emoji;
          };
          sizes.applications = 11;
        };

        # Only the apps listed here. Left on, autoEnable writes config for every app
        # Stylix knows (Blender, Vencord, ...) and takes over VSCodium's settings.json.
        autoEnable = false;
        targets = {
          gtk = {
            enable = true;
            # Stylix's accent is base0D (blue); the desktop's is the accent role.
            extraCss = ''
              @define-color accent_color #${ui.accent};
              @define-color accent_bg_color #${ui.accent};
              @define-color accent_fg_color #${ui.onAccent};
            '';
          };
          qt.enable = true;
          zen-browser = {
            enable = true;
            profileNames = [ "default" ];
          };
          fontconfig.enable = true;
          bat.enable = true;
          btop.enable = true;
          lazygit.enable = true;
          tmux.enable = true;
          nixcord.enable = true; # Equicord, apps/chat/discord.nix
          spicetify.enable = true; # apps/media/spotify.nix
          # Its font only: apps/terminal/ghostty.nix has Catppuccin's own ANSI colours.
          ghostty = {
            enable = true;
            colors.enable = false;
          };
          # Not here, drawn by hand from the palette instead: Hyprland's gradient
          # border (hyprland/appearance.nix) and the prompt (shell/starship.nix).
          # VSCodium keeps the official Catppuccin theme extension.
        };
      };

      # colorScheme sets org.gnome.desktop.interface color-scheme = prefer-dark, which
      # the GTK portal hands to libadwaita, Firefox/Zen, Chromium and Electron apps.
      gtk.colorScheme = "dark";

      # GTK settings GUI.
      home.packages = [ pkgs.nwg-look ];
      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("SUPER + comma", hl.dsp.exec_cmd("nwg-look"))
      '';
    };
}
