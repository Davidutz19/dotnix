# Boot loader: Limine, signed for Secure Boot with sbctl. Its look is in
# users/davidutz/theme.nix, extra entries (Windows) in the host.
#
# How the chain is checked: the firmware only runs Limine signed with our key. That
# binary carries the hash of limine.conf (enrollConfig), and limine.conf carries the
# hash of every kernel and initrd. A changed file stops the boot, and the editor is
# off, so nobody can add `init=/bin/sh` at the menu.
#
# The keys live in /var/lib/sbctl (preserved by system/impermanence.nix). Setting up a
# new machine, with the firmware in Secure Boot setup mode:
#   sudo sbctl create-keys
#   rebuild                                  # installs and signs Limine
#   sudo sbctl enroll-keys --microsoft --firmware-builtin
#   reboot, turn Secure Boot on in the firmware, then `sbctl status`
# --microsoft keeps Microsoft's keys: Windows' boot manager and the GPU's firmware
# (option ROM) are signed with them, and without them the screen stays black.
{
  flake.nixosModules.boot =
    { config, ... }:
    {
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.limine = {
        enable = true;
        maxGenerations = 10;
        secureBoot.enable = true;
        panicOnChecksumMismatch = true; # also turns on enrollConfig
      };

      environment.systemPackages = [ config.boot.loader.limine.secureBoot.sbctl ];
    };
}
