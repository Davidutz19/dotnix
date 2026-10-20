# VM test for the root wipe and preservation, using the real disk layout of desktop-btw
# (shrunk ESP: the test disks are 4 GiB). Runs with `nix flake check` and needs KVM.
#
# It checks that disko's format step is idempotent (disko's own test harness formats
# twice), that the root opens from LUKS, that `/` and /home are empty after a reboot,
# and that /persist, the machine-id, the SSH host key, the preserved home paths and
# the data disk mounts inside the home survive it.
{ self, inputs, ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    {
      checks = lib.optionalAttrs (system == "x86_64-linux") {
        impermanence = inputs.disko.lib.testLib.makeDiskoTest {
          inherit pkgs;
          name = "impermanence";
          disko-config = lib.recursiveUpdate self.diskoConfigurations.desktop-btw {
            disko.devices.disk.system.content.partitions = {
              ESP.size = "512M";
              # The test VM has no TPM: the root opens with the key file disko's test
              # harness writes (/tmp/secret.key).
              root.content.settings.keyFile = "/tmp/secret.key";
            };
          };
          extraSystemConfig = {
            imports = [ self.nixosModules.impermanence ];
            boot.initrd.systemd.enable = true;
            services.openssh.enable = true; # its host keys are preserved as symlinks

            # The same shape as nixosModules.davidutz, without home-manager.
            users.groups.davidutz.gid = 1000;
            users.users.davidutz = {
              isNormalUser = true;
              uid = 1000;
              group = "davidutz";
            };
            preservation.preserveAt."/persist".users.davidutz = {
              directories = [
                {
                  directory = ".ssh";
                  mode = "0700";
                }
                ".local/share/zsh"
              ];
              files = [ ".claude.json" ];
            };
          };
          extraTestScript = ''
            def no_failed_units():
                failed = machine.succeed("systemctl --failed --no-legend --plain").strip()
                assert failed == "", f"failed units:\n{failed}"

            home = "/home/davidutz"

            machine.wait_for_unit("multi-user.target")
            machine.wait_for_unit("sshd.service")
            no_failed_units()
            machine.succeed("test \"$(findmnt -no SOURCE /persist | cut -d[ -f1)\" = /dev/mapper/cryptroot")

            # state written during the first boot
            machine.succeed("test -L /etc/machine-id")
            machine_id = machine.succeed("cat /etc/machine-id").strip()
            host_key = machine.succeed("cat /etc/ssh/ssh_host_ed25519_key.pub").strip()
            machine.succeed("touch /etc/should-vanish")
            machine.succeed("mkdir -p /var/log/probe && touch /var/log/probe/should-stay")
            machine.succeed(f"su davidutz -c 'touch {home}/should-vanish {home}/.ssh/should-stay {home}/.local/share/zsh/should-stay'")
            machine.succeed(f"touch {home}/personal/should-stay") # a fresh subvolume, owned by root
            machine.succeed(f"su davidutz -c 'echo kept > {home}/.claude.json'")
            machine.succeed("sync")

            machine.shutdown()
            machine.start()
            machine.wait_for_unit("multi-user.target")
            machine.wait_for_unit("sshd.service")
            no_failed_units()

            machine.fail("test -e /etc/should-vanish")
            machine.succeed("test -e /var/log/probe/should-stay")
            assert machine.succeed("cat /etc/machine-id").strip() == machine_id, "machine-id changed"
            assert machine.succeed("cat /etc/ssh/ssh_host_ed25519_key.pub").strip() == host_key, "ssh host key changed"

            machine.fail(f"test -e {home}/should-vanish")
            for kept in [".ssh/should-stay", ".local/share/zsh/should-stay", "personal/should-stay"]:
                machine.succeed(f"test -e {home}/{kept}")
            assert machine.succeed(f"cat {home}/.claude.json").strip() == "kept", ".claude.json lost"
            assert machine.succeed(f"stat -c '%U %a' {home}").strip() == "davidutz 700", "home owner or mode wrong"
            assert machine.succeed(f"stat -c '%U %a' {home}/.ssh").strip() == "davidutz 700", ".ssh owner or mode wrong"
            assert machine.succeed(f"stat -c '%U' {home}/.local/share").strip() == "davidutz", ".local/share not the user's"

            # the previous root is kept for recovery
            machine.succeed("mkdir -p /top && mount -o subvol=/ $(findmnt -no SOURCE /persist | cut -d[ -f1) /top")
            machine.succeed("test -n \"$(ls /top/old_roots)\"")
          '';
        };
      };
    };
}
