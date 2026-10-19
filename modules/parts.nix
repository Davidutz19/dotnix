{ inputs, ... }:
{
  imports = [
    inputs.home-manager.flakeModules.home-manager # adds the homeModules and homeConfigurations outputs
    inputs.disko.flakeModules.disko # adds the diskoConfigurations output
  ];
  # The desktop, and the pi through standalone.nix.
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  # `nix fmt` formats every .nix file in the repo.
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-tree;
    };
}
