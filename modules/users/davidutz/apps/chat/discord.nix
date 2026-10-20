# Discord with Equicord (a client mod: plugins and themes), through nixcord. On
# workspace 10, the second monitor. Stylix themes it (theme.nix).
#
# Equicord's settings are declared in `programs.nixcord.config` and written on every
# activation (each boot here), so a plugin toggled in the app is back to this file's
# state after a reboot. Enable plugins here:
#   programs.nixcord.config.plugins.<name>.enable = true;
# Their names and options: https://github.com/FlameFlag/nixcord (docs/).
# Discord's own settings.json isn't managed, so Discord keeps its window state there.
{ inputs, ... }:
{
  flake.homeModules.davidutzDesktop = {
    imports = [ inputs.nixcord.homeModules.nixcord ];

    programs.nixcord = {
      enable = true;
      discord = {
        equicord.enable = true;
        # WebRTCPipeWireCapturer is what makes screen sharing work on Wayland.
        commandLineArgs = [
          "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer"
          "--ozone-platform=wayland"
          "--enable-gpu-rasterization"
          "--enable-zero-copy"
          "--ignore-gpu-blocklist"
        ];
      };
    };

    davidutz.persist.directories = [
      ".config/discord" # login and Discord's own settings
      ".config/Equicord" # plugin data and themes
    ];

    wayland.windowManager.hyprland.extraConfig = ''
      hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("discord"))
      hl.window_rule({ name = "discord", match = { class = "discord" }, workspace = "10" })
    '';
  };
}
