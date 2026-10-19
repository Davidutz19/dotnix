{
  flake.homeModules.davidutz =
    { pkgs, ... }:
    {
      programs.git = {
        enable = true;
        settings = {
          user.name = "David Gheghea";
          user.email = "71325082+DavidutzDev@users.noreply.github.com";
          init.defaultBranch = "main";
          pull.rebase = true;
        };
      };

      programs.lazygit.enable = true;

      # GitHub CLI (`gh`): pull requests, issues and forks. `gh auth login` once;
      # git then pushes over HTTPS with the same credentials.
      programs.gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };

      # Forgejo CLI (`fj`): issues, pull requests and releases on Forgejo instances
      # such as Codeberg. `fj auth login` once per instance.
      home.packages = [ pkgs.forgejo-cli ];

      # gh and fj logins.
      davidutz.persist.directories = [
        ".config/gh"
        ".local/share/forgejo-cli"
      ];
    };
}
