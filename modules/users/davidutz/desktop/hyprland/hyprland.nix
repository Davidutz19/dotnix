# Hyprland, rendered to ~/.config/hypr/hyprland.lua.
# The host must import nixosModules.hyprland (modules/system/hyprland.nix).
#
# The config is plain Lua in `wayland.windowManager.hyprland.extraConfig`, and every
# file adds the part it owns: an app its launch key and window rules, mochi.nix the
# shell's keys, the host its monitors. The Lua API is in the stubs that
# ~/.config/hypr/.luarc.json points to, and at https://wiki.hypr.land.
{
  flake.homeModules.davidutzDesktop =
    { config, ... }:
    let
      cursor = config.home.pointerCursor;
    in
    {
      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";
        # Use the packages from the NixOS module so both sides run the same build.
        package = null;
        portalPackage = null;
        # UWSM starts the systemd session, so home-manager's own target is not needed.
        systemd.enable = false;

        extraConfig = ''
          -- The theme comes from `home.pointerCursor` in theme.nix. home-manager writes
          -- it to the shell session too, but a graphical login never reads that, so
          -- Hyprland exports it for everything it starts.
          hl.env("XCURSOR_THEME", "${cursor.name}")
          hl.env("XCURSOR_SIZE", "${toString cursor.size}")
          -- phinger-cursors ships no hyprcursor theme, so Hyprland falls back to
          -- XCursor. The size is set anyway to keep the two in step if that changes.
          hl.env("HYPRCURSOR_SIZE", "${toString cursor.size}")

          hl.env("GDK_BACKEND", "wayland,x11,*")
          hl.env("SDL_VIDEODRIVER", "wayland")
          hl.env("CLUTTER_BACKEND", "wayland")

          hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
          hl.env("XDG_SESSION_TYPE", "wayland")
          hl.env("XDG_SESSION_DESKTOP", "Hyprland")

          hl.env("QT_QPA_PLATFORM", "wayland;xcb")
          hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
          hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
        '';
      };

      services.hyprpolkitagent.enable = true;
    };
}
