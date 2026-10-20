# Wallpapers: the awww daemon, the images in ~/Pictures/Wallpapers, and the picker
# on Mochi's island (SUPER + CTRL + W), a plugin from ~/personal/mochi-wallpaper-selector.
# The picker sets a wallpaper with awww, saves it, and sets it again at login.
{ inputs, ... }:
{
  flake.homeModules.davidutzDesktop =
    { lib, pkgs, ... }:
    let
      # From wallhaven, fetched by hash rather than committed. To add one: its
      # file name and `hash = "";`, rebuild, and copy the hash Nix reports.
      wallhaven = {
        "wallhaven-o5jv65.jpg" = "sha256-bMYij70tl4RmzGLnsmcjg6wtBDVnL71gO9ox6g2MUcs=";
        "wallhaven-y8g69d.jpg" = "sha256-4lPQIvvcdutl5bWcTNFrAyTEgRNfPkFoJbKUV9S/IjM=";
        "wallhaven-yqj21x.jpg" = "sha256-gFM4cmQr+VaIeNBVQCvqz+R56LiKwTl+5Duqd6ywTgs=";
        "wallhaven-je8p85.jpg" = "sha256-N8ekamcZZlib/iDsIYbfb2bUx6Nxc/XwxhOLtwIl1Dw=";
        "wallhaven-zpx3xw.png" = "sha256-WzJacHB9WEnq1QFdGIdZy4XqDNUHOxjqzYz9wW4aYRw=";
        "wallhaven-1qkz23.png" = "sha256-bNpCoBt0TRHDNisNNYcDHRK/1qsanP6tzxDloE9SOy4=";
        "wallhaven-2y16jm.png" = "sha256-2ejdDP+CRbzqOl97U6Ia/y5T83wdhPLZXLeVwMTXnNo=";
      };
      fetch =
        name: hash:
        pkgs.fetchurl {
          inherit name hash;
          # wallhaven files sit under the first two letters of their id.
          url = "https://w.wallhaven.cc/full/${builtins.substring 10 2 name}/${name}";
        };
    in
    {
      services.awww.enable = true;

      # Linked one by one, so wallpapers added by hand stay put.
      home.file = {
        "Pictures/Wallpapers" = {
          source = ./images;
          recursive = true;
        };
      }
      // lib.mapAttrs' (
        name: hash: lib.nameValuePair "Pictures/Wallpapers/${name}" { source = fetch name hash; }
      ) wallhaven;

      programs.mochi = {
        plugins.wallpaper.src = inputs.mochi-wallpaper-selector;
        settings.modules = [ "wallpaper" ];
        settings.module.wallpaper = {
          daemon = "awww";
          transition = "grow";
          # Until one is picked; after that, the last one picked.
          default = "wallhaven-o5jv65.jpg";
        };
      };

      # The wallpaper picked last.
      davidutz.persist.directories = [ ".local/state/mochi-wallpaper" ];

      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("SUPER + CTRL + W", hl.dsp.exec_cmd("mochi ipc wallpaper toggle"))
      '';
    };
}
