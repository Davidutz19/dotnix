# dotnix

NixOS and home-manager config for desktop-btw, plus a home-manager-only setup for
machines without NixOS (the pi).

## Commands

```sh
rebuild                       # nh os switch: build and activate
update                        # nh os switch --update: bump flake.lock first
cleanup                       # nh clean all --keep 5
nix flake check               # evaluates every host and home config, runs the VM test (needs KVM)
nix fmt                       # formats every .nix file
home-manager switch --flake . # machines without NixOS (standalone.nix)
```

## Layout

Every `.nix` file under `modules/` is a flake-parts module, loaded by `import-tree`.
Nothing lists files by hand, so creating a file registers it. Directories and files
starting with `_` are skipped.

```
modules/
  parts.nix               systems, formatter, flake-parts imports
  checks/                 VM test of the root wipe (nix flake check)
  system/<name>.nix       machine features: nixosModules.<name>
  hosts/<host>/           hardware, disks (disko), host settings; picks system features
                          and the user's profiles; monitors and GPU env for Hyprland
  users/davidutz/         everything about you; every file adds to one of:
                            nixosModules.davidutz        account, login shell
                            homeModules.davidutz         terminal setup (everywhere)
                            homeModules.davidutzDesktop  Hyprland, GUI apps, T3 Code
                            homeModules.davidutzAgents   Claude Code, agy, skills
    account.nix           the account and the `hm` alias
    persist.nix           home state that survives the reboot (davidutz.persist)
    standalone.nix        homeConfigurations for machines without NixOS
    theme.nix             the palette, cursor, GTK and Qt
    shell/                zsh, starship, zoxide, direnv, atuin, eza
    cli/                  git, tmux, neovim, command-line utilities
    desktop/              hyprland/, mochi (the shell), audio, brightness,
                          clipboard, wallpapers/
    apps/<category>/      one file per GUI app
    agents/               one file per coding agent
```

Several files set the same module (`homeModules.davidutzDesktop`) and the module
system merges them, so a user file doesn't import anything. An app's file holds
everything about it: the package, its settings, its launch key (`hl.bind`), its window
rules (`hl.window_rule`), its MIME defaults and the state it keeps across reboots
(`davidutz.persist`).

To add something:

- Something only you use: a new file in the matching directory of
  `modules/users/davidutz/` that sets `flake.homeModules.davidutz` (terminal) or
  `flake.homeModules.davidutzDesktop` (GUI). If it needs a system setting too, set
  `flake.nixosModules.davidutz` in the same file, as `shell/zsh.nix` does.
- Something the machine provides (Steam, Docker, NVIDIA): a new file in
  `modules/system/` that sets `flake.nixosModules.<name>`, then add `<name>` to the
  `imports` of each host that should have it.

Prefer a home-manager `programs.<app>` or `services.<app>` module when it configures
something, and a plain `home.packages` entry otherwise.

## Hyprland

The config is Lua in `wayland.windowManager.hyprland.extraConfig`, rendered to
`~/.config/hypr/hyprland.lua`. Each file writes the part it owns. Commands that run
once at startup go in `hl.on("hyprland.start", function() ... end)`; daemons are
systemd user services. Check the result with
`Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.

## Impermanence

`/` and `/home` are an empty btrfs subvolume after every boot. The initrd moves the
old one to `old_roots/` and keeps it 14 days (`system/impermanence.nix`).

- System state that survives is listed in `system/impermanence.nix`.
- Home state is listed by the file that configures it, in `davidutz.persist`.
  Everything else in the home is gone after a reboot: caches, `~/go`, `~/.cargo`,
  `~/.npm`, and the config of apps nobody listed.
- `~/personal` and `~/work` are subvolumes on the data disk, mounted into the home.
  The wipe doesn't touch them.

An app lost its settings after a reboot? Find where it writes and add the path to its
file:

```sh
find ~ -xdev -newer /etc/os-release -not -path '*/.cache/*' | less
```

A file you forgot is still in the previous root for 14 days:

```sh
sudo mount -o subvol=/ /dev/disk/by-partuuid/205bd0a2-e61a-451d-84c3-2696a7a1e0f6 /mnt
ls /mnt/old_roots
```

References: https://github.com/mightyiam/dendritic, https://flake.parts,
https://nix-community.github.io/preservation/
