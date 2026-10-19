# Skills and instructions from the dotagents repo. The repo ships the Home Manager
# module that links them, so this file only imports it and sets the harnesses this
# machine runs. Updates come from `nix flake update dotagents`.
{ inputs, ... }:
{
  flake.homeModules.davidutzAgents = {
    imports = [ inputs.dotagents.homeModules.default ];

    # opencode is not installed here, and enabling it would create
    # ~/.config/opencode for nothing.
    dotagents.opencode.enable = false;
  };
}
