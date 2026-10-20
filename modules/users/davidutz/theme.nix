# One colour palette for everything (Catppuccin Mocha).
#
# `davidutz.theme.colors` is the source. Stylix turns it into a base16 scheme and
# themes the apps it supports (GTK, Qt, Zen, Discord, Spotify, bat, tmux, ...), with the
# cursor, icons and fonts. Starship, Hyprland, ghostty, Mochi and the boot menu read
# the palette by colour name. Switching the palette here switches all of them.
# The palette is in the base profile, so the terminal setup has it without a desktop.
{ inputs, ... }:
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

  # The boot menu (Limine, system/boot.nix), in the same palette. Does nothing on
  # hosts that boot with something else.
  flake.nixosModules.davidutz =
    { config, ... }:
    let
      c = config.hm.davidutz.theme.colors;
    in
    {
      boot.loader.limine.style = {
        wallpapers = [ ./desktop/wallpapers/images/seaside-sunset.jpg ];
        wallpaperStyle = "stretched";
        backdrop = c.crust;
        interface = {
          branding = config.networking.hostName;
          brandingColor = c.lavender;
          helpColor = c.overlay1;
        };
        graphicalTerminal = {
          # Catppuccin's terminal order: black, red, green, brown, blue, magenta, cyan, gray.
          palette = "${c.surface1};${c.red};${c.green};${c.yellow};${c.blue};${c.pink};${c.teal};${c.subtext0}";
          brightPalette = "${c.surface2};${c.red};${c.green};${c.yellow};${c.blue};${c.pink};${c.teal};${c.subtext1}";
          foreground = c.text;
          background = "33${c.base}"; # TTRRGGBB, TT is transparency: base at 20% over the wallpaper
          brightForeground = c.lavender;
          brightBackground = c.surface0;
        };
      };
    };

  flake.homeModules.davidutzDesktop =
    { config, pkgs, ... }:
    let
      c = config.davidutz.theme.colors;
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
        # Catppuccin's own base16 mapping.
        base16Scheme = with c; {
          scheme = "Catppuccin Mocha (dotnix)";
          author = "Catppuccin";
          base00 = base;
          base01 = mantle;
          base02 = surface0;
          base03 = surface1;
          base04 = surface2;
          base05 = text;
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

        # Papirus with its folders in the palette's lavender.
        icons = {
          enable = true;
          package = pkgs.catppuccin-papirus-folders.override {
            flavor = "mocha";
            accent = "lavender";
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
            # Stylix's accent is base0D (blue); the rest of the desktop uses lavender.
            extraCss = ''
              @define-color accent_color #${c.lavender};
              @define-color accent_bg_color #${c.lavender};
              @define-color accent_fg_color #${c.crust};
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
