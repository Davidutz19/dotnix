# Mochi, the desktop shell: bar, launcher, notifications, OSD, lock screen and power
# menu, from the `mochi` flake input.
{ inputs, ... }:
{
  # Recording (the capture module) goes through gpu-screen-recorder's setcap wrapper;
  # without it the polkit request for capture rights fails.
  flake.nixosModules.davidutz.programs.gpu-screen-recorder.enable = true;
  # The lock screen checks the password with this PAM service; Mochi refuses
  # to lock without it.
  flake.nixosModules.davidutz.security.pam.services.mochi = { };

  flake.homeModules.davidutzDesktop =
    { config, pkgs, ... }:
    let
      ui = config.davidutz.theme.ui;
    in
    {
      imports = [ inputs.mochi.homeModules.default ];

      # For files dropped on the island: ffmpeg converts videos and sound,
      # vtracer traces images into SVG.
      home.packages = [
        pkgs.ffmpeg
        pkgs.vtracer
      ];

      programs.mochi = {
        enable = true;

        # The latest release, already built, so the switch compiles nothing.
        # `nix flake update mochi` moves it to the newest release.
        package = inputs.mochi.packages.${pkgs.stdenv.hostPlatform.system}.mochi-bin;

        # Mochi asks for every password on the island: polkit's admin prompts in
        # place of hyprpolkitagent, which this turns off, and sudo -A and ssh
        # through SUDO_ASKPASS and SSH_ASKPASS. Both need "auth" in modules.
        polkitAgent.enable = true;
        askpass.enable = true;

        settings = {
          bento.i_really_understand_that_bento_can_harm_and_contain_malicious_content = true;
          bubbles.stack = true;
          island.notices = "focus";
          module = {
            audio.max_volume = 200;
            clock = {
              day_progress = "ring";
              zones = [
                "Europe/London"
                "America/New_York"
                "Asia/Tokyo"
                "Europe/Brussels"
              ];
            };
            idle.hover = [
              "workspaces"
              "show"
            ];
            performance = {
              cpu = {
                critical = 95;
                notice = 85;
              };
              temperature = {
                critical = 90;
                notice = 80;
              };
            };
            tray.pinned = [ "discord" ];
            weather.place = "Liege, Belgium";
          };
          modules = [
            "idle"
            "osd"
            "workspaces"
            "media"
            "audio"
            "notifications"
            "launcher"
            "control-center"
            "power"
            "lock"
            "auth"
            "capture"
            "share"
            "clipboard"
            "tray"
            "network"
            "bluetooth"
            "battery"
            "brightness"
            "privacy"
            "nightlight"
            "drop"
            "performance"
            "widgets"
            "notes"
            "emoji"
            "colors"
            "settings"
            "tour"
            "updater"
            "clock"
            "weather"
            "timer"
          ];
        };
        # The roles from theme.nix, which are those of Mochi's Catppuccin preset.
        # The island's background is 96% opaque (f5).
        theme = {
          colors = {
            background = "#f5${ui.background}";
            surface = "#${ui.surface}";
            raised = "#${ui.raised}";
            highlight = "#${ui.highlight}";
            foreground = "#${ui.foreground}";
            muted = "#${ui.muted}";
            accent = "#${ui.accent}";
            on_accent = "#${ui.onAccent}";
            danger = "#${ui.danger}";
            success = "#${ui.success}";
          };
          text.family = config.stylix.fonts.monospace.name;
        };
      };

      # Widget layouts and settings changed live, then the clipboard history, notes,
      # reminders and notification history.
      davidutz.persist.directories = [
        ".config/mochi"
        ".local/state/mochi"
      ];

      wayland.windowManager.hyprland.extraConfig = ''
        -- Mochi's lock screen. Locking also makes sudo, the SSH keys, polkit and
        -- the keyring forget their passwords (the auth module).
        hl.bind("SUPER + L", hl.dsp.exec_cmd("mochi ipc lock lock"))
        hl.bind("SUPER + space", hl.dsp.exec_cmd("mochi ipc launcher toggle"))
        hl.bind("SUPER + C", hl.dsp.exec_cmd("mochi ipc hub toggle"))
        hl.bind("SUPER + N", hl.dsp.exec_cmd("mochi ipc notifications history"))
        hl.bind("SUPER + V", hl.dsp.exec_cmd("mochi ipc clipboard toggle"))
        hl.bind("SUPER + A", hl.dsp.exec_cmd("mochi ipc audio toggle"))
        -- Mutes the default microphone, or unmutes it; the OSD shows which.
        hl.bind("SUPER + Backspace", hl.dsp.exec_cmd("mochi ipc audio mute input"), { locked = true })
        hl.bind("SUPER + Y", hl.dsp.exec_cmd("mochi ipc tray toggle"))
        hl.bind("SUPER + I", hl.dsp.exec_cmd("mochi ipc hub open performance/page"))
        -- Every option, changed live; Copy gives them back as Nix for this file.
        hl.bind("SUPER + SHIFT + comma", hl.dsp.exec_cmd("mochi ipc settings toggle"))
        hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("mochi ipc notifications dnd toggle"))

        -- The emoji grid, and a color picked from the screen.
        hl.bind("SUPER + period", hl.dsp.exec_cmd("mochi ipc emoji toggle"))
        hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("mochi ipc colors pick"))

        -- Closes whatever the island shows. Escape only reaches views that take the
        -- keyboard (launcher, hub, mixer); notices like the volume let it through.
        hl.bind("SUPER + Escape", hl.dsp.exec_cmd("mochi dismiss"))

        -- Arrange the desktop widgets on the focused monitor; Escape or Done stops.
        hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("mochi ipc widgets edit"))

        -- Power page of the hub: power profiles, suspend, reboot, shut down.
        hl.bind("XF86Launch1", hl.dsp.exec_cmd("mochi ipc hub open power/power"))
        hl.bind("SUPER + M", hl.dsp.exec_cmd("mochi ipc power logout"))

        -- Print picks a region, window or screen; ALT + Print records, and stops
        -- the recording when pressed again. CTRL takes the whole screen at once.
        hl.bind("Print", hl.dsp.exec_cmd("mochi ipc capture screenshot"))
        hl.bind("ALT + Print", hl.dsp.exec_cmd("mochi ipc capture record"))
        hl.bind("CTRL + Print", hl.dsp.exec_cmd("mochi ipc capture screenshot screen"))
        hl.bind("CTRL + XF86Launch1", hl.dsp.exec_cmd("mochi ipc capture screenshot screen"))
        hl.bind("ALT + XF86Launch1", hl.dsp.exec_cmd("mochi ipc capture screenshot window"))

        hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("mochi ipc media play-pause"), { locked = true })
        hl.bind("XF86AudioPause", hl.dsp.exec_cmd("mochi ipc media play-pause"), { locked = true })
        hl.bind("XF86AudioStop", hl.dsp.exec_cmd("mochi ipc media pause"), { locked = true })
        hl.bind("XF86AudioNext", hl.dsp.exec_cmd("mochi ipc media next"), { locked = true })
        hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("mochi ipc media previous"), { locked = true })
      '';
    };
}
