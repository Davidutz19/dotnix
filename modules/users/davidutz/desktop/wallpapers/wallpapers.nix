# Wallpaper daemon (awww), the wallpaper it shows, and the wallpapers in
# ~/Pictures/Wallpapers.
{
  flake.homeModules.davidutzDesktop =
    { config, pkgs, ... }:
    let
      # Fetched by hash rather than committed. To change it: point `url` at the new
      # image, set `hash = "";`, rebuild, and copy the hash Nix reports.
      wallpaper = pkgs.fetchurl {
        name = "wallhaven-o5jv65.jpg";
        url = "https://w.wallhaven.cc/full/o5/wallhaven-o5jv65.jpg";
        hash = "sha256-bMYij70tl4RmzGLnsmcjg6wtBDVnL71gO9ox6g2MUcs=";
      };
    in
    {
      services.awww.enable = true;

      # Sets the wallpaper once the daemon runs. awww keeps the last image in
      # ~/.cache, which is wiped on boot, so it is set again on every login. Retries
      # until the daemon's socket is up.
      systemd.user.services.awww-wallpaper = {
        Unit = {
          Description = "Set the wallpaper with awww";
          After = [ "awww.service" ];
          PartOf = [ "awww.service" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${config.services.awww.package}/bin/awww img ${wallpaper}";
          Restart = "on-failure";
          RestartSec = 1;
        };
        Install.WantedBy = [ "awww.service" ];
      };

      # Linked one by one, so wallpapers added by hand stay put.
      home.file = {
        "Pictures/Wallpapers" = {
          source = ./images;
          recursive = true;
        };
        "Pictures/Wallpapers/${wallpaper.name}".source = wallpaper;
      };
    };
}
