{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";

    # Declarative disk layout: partitions, filesystems, btrfs subvolumes.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Keeps chosen state across the root wipe on every boot.
    preservation.url = "github:nix-community/preservation";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # The desktop shell: bar, launcher, notifications, OSD and power menu.
    mochi = {
      url = "github:DavidutzDev/mochi";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming for every app it knows, from the palette in users/davidutz/theme.nix.
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # Declarative Flatpak apps and remotes (Sober).
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    # Agent skills and instructions, linked in by the agents profile. It is a flake, so
    # the Home Manager module that links them ships with the repo. It has no inputs of
    # its own, so there is nothing to follow.
    dotagents.url = "github:DavidutzDev/dotagents";

    # League of Legends through Darling. It pins its own nixpkgs on purpose: the
    # Darling build is tested against that toolchain.
    # Temporarily on the fd-limit fix until lucannez64/darling-lol#107 is merged.
    darling-lol.url = "github:DavidutzDev/darling-lol/fix/darlingserver-fd-limit";
  };

  outputs =
    inputs@{
      flake-parts,
      home-manager,
      import-tree,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (import-tree ./modules);
}
