# Control surface for coding agents, local or on another machine. Machines that run
# the agents themselves also get the agents profile (agents/). The nixpkgs package
# puts codex, gh and git on T3 Code's PATH.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.t3code ];

      # T3 Code writes this desktop file into ~/.local/share/applications itself,
      # but can't register it: home-manager owns mimeapps.list.
      xdg.mimeApps.defaultApplications."x-scheme-handler/t3code" = "com.t3tools.T3Code.desktop";

      davidutz.persist.directories = [
        ".t3" # threads, worktrees and attachments
        ".config/T3 Code (Alpha)"
        ".codex"
      ];
    };
}
