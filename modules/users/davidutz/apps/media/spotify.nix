# Spotify with Spicetify (themes, extensions), on workspace 10, the second monitor.
# Stylix themes it (theme.nix). Spicetify patches Spotify at build time, so nothing
# is injected at runtime and an update comes with `nix flake update`.
#
# Extensions and custom apps from spicetify-nix's catalogue:
#   programs.spicetify.enabledExtensions = with spicePkgs.extensions; [ shuffle ];
# with spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}.
# List: https://gerg-l.github.io/spicetify-nix/
{ inputs, ... }:
{
  flake.homeModules.davidutzDesktop = {
    imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];

    programs.spicetify.enable = true;

    davidutz.persist.directories = [ ".config/spotify" ]; # login; the song cache is dropped

    wayland.windowManager.hyprland.extraConfig = ''
      hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("spotify"))
      hl.window_rule({ name = "spotify", match = { class = "Spotify" }, workspace = "10" })
    '';
  };
}
