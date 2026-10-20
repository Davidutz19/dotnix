# TODO

Open work only. The layout and commands are in README.md.

## Impermanence follow-up

- [ ] After the first boot with the wiped home, use the machine for a few days. Add
      anything that lost its settings to `davidutz.persist` in its file.
- [ ] Then delete the old home subvolume, which still holds everything:
      mount the top level (README.md, Impermanence) and run
      `sudo btrfs subvolume delete /mnt/@home`. Copy anything you want from it first.
- [ ] Snapshots of the data disk subvolumes (`personal`, `work`, `Games`) with snapper:
      https://wiki.nixos.org/wiki/Snapper. `/` doesn't need them, and `/persist`
      could get one too.

## Temporary pins

- [ ] `darling-lol` points at the fd-limit fix branch of the fork. Move the input back
      to `github:lucannez64/darling-lol` once lucannez64/darling-lol#107 is merged.

## Install leftovers

- [ ] Secrets with sops-nix (`~/.config/sops` is preserved). First users: the
      password hash (now `/persist/passwords/davidutz`), Wi-Fi PSKs, the Tailscale
      auth key. Point it at the preserved host key:
      `sops.age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];`
- [ ] Add your SSH public key to `users.users.davidutz.openssh.authorizedKeys.keys`.
      Password login over SSH is off, so without a key you can't reach the machine
      while the GPU is in the VM.
- [ ] Once Limine with Secure Boot has booted a few times: delete systemd-boot's
      leftovers on the ESP (`/boot/loader`, `/boot/EFI/systemd`, `/boot/EFI/nixos`, and its
      fallback copy `/boot/EFI/BOOT/BOOTX64.EFI`) and its
      firmware entry ("Linux Boot Manager", `efibootmgr -b <num> -B`).

## Still in `~/personal/dotfiles`

- [ ] ssh-agent with the 30-minute key timeout: `services.ssh-agent.enable = true;`
      (Mochi already provides `SSH_ASKPASS`).
- [ ] Zen's `.zen-chrome/*.css`: `programs.zen-browser.profiles.default.userChrome`
      and `userContent`.
- [ ] wepapered and nekoland: not packaged. Package them, then give each an `apps/` file.
- [ ] `bin/` binaries (`ccd`, `cco`, `ficsit`, `herdr`, `ironfoil`, `nekoland`, `rtk`)
      and the `jcode`/`t3` symlinks: package them or use nixpkgs.
- [ ] Idle: lock or turn the screens off after a while (`services.hypridle`).
- [ ] Standalone desktop on another distro: add `targets.genericLinux.nixGL` before
      giving such a machine `davidutzDesktop`.
- [ ] Archive the dotfiles repo once this list is empty.

## Machine

- [ ] Single-GPU passthrough: check the `~/win-vm` scripts on NixOS (shebangs and
      `/usr/...` paths, `display-manager.service` instead of `sddm`, `tss` group for
      the TPM with `security.tpm2.enable = true;`).
- [ ] Firewall: compare with CachyOS's ufw rules and add missing ports to
      `networking.firewall.allowedTCPPorts`.
- [ ] `verdaccio.service` as `systemd.user.services.verdaccio` (its storage would need
      a `davidutz.persist` entry too).
- [ ] SDDM theme: `services.displayManager.sddm.theme`.
- [ ] Optional: sched-ext (`services.scx`), the CachyOS kernel
      (https://github.com/xddxdd/nix-cachyos-kernel, check `legacy_580` builds),
      Solaar (`hardware.logitech.wireless`), printing (`services.printing`).

## Apps

- [ ] Neovim config: copy `~/.config/nvim` into the repo and link it with
      `xdg.configFile."nvim".source`, then drop `.config/nvim` from `cli/neovim.nix`'s
      persist list.
- [ ] Not ported yet: chromium, equibop or Vencord (https://github.com/KaylorBen/nixcord),
      Spicetify (https://github.com/Gerg-L/spicetify-nix), rustdesk, winbox, megasync,
      ventoy, steamcmd, Vinegar (Roblox Studio), truckersmp-cli.
- [ ] LocalSend can't receive until its port is open: replace the package in
      `apps/files/localsend.nix` with `programs.localsend = { enable = true; openFirewall = true; };`
      at NixOS level.
- [ ] XDG user dirs: `xdg.userDirs = { enable = true; createDirectories = true; };`
- [ ] Unreal Engine on `/opt/unreal-engine` expects an FHS system: nix-ld is on; a
      `buildFHSEnv` wrapper if that isn't enough. Rider is `jetbrains.rider`.

## Development

- [ ] Per-project dev shells (`flake.nix` + `.envrc` with `use flake`) over global
      toolchains. Global ones CachyOS had: go, dotnet-sdk, php + composer, python + uv,
      nodejs + pnpm + bun, rustup, cmake, opentofu, kubectl, ansible.
- [ ] VSCodium extensions through `programs.vscode.profiles.default.extensions`.

## Repo

- [ ] Lint with `statix check` and `deadnix`.
- [ ] CI running `nix flake check`.
- [ ] If the pi runs NixOS: a host under `modules/hosts/pi/` with nixos-hardware, and
      drop its standalone entry.
