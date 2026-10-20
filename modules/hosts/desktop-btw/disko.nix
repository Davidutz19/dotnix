# Disk layout of desktop-btw. The boot-time wipe of `/` is in system/impermanence.nix.
#
#   system  Phison E12 512G   ESP + LUKS2 (cryptroot) holding btrfs:
#                                           @ (/ and /home, wiped every boot)  @nix  @persist
#   data    WD SN7100 2TB     one btrfs:    top level at /mnt/bulkfast, each former
#                                           folder is now a subvolume with the same name
#
# The partition GUIDs are the existing CachyOS ones. disko mounts by GUID, so the
# current partitions match this layout without being recreated.
#
# `disko --mode format,mount` is safe on these disks: it only creates filesystems on
# empty partitions and only creates missing subvolumes. NEVER run `--mode destroy` or
# `destroy,format,mount`: that wipes both disks. See INSTALL.md.
{ self, inputs, ... }:
let
  btrfsOpts = [
    "compress=zstd:1"
    "noatime"
  ];
  # Data mounts must not stop boot if the disk is missing. x-gvfs-hide keeps them out
  # of Nautilus's drive list; ~/personal and ~/work are bookmarks there instead.
  dataOpts = [
    "compress=zstd"
    "noatime"
    "nofail"
    "x-gvfs-hide"
  ];
in
{
  # Plain layout, also used by the VM test in modules/checks/impermanence.nix.
  flake.diskoConfigurations.desktop-btw = {
    disko.devices.disk.system = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-E12-512G-PHISON-SSD-B3-BB1_D6EB0791116600007761";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            uuid = "d9fb7e0d-475f-46f1-bf1b-a68c04e0b67a";
            type = "EF00";
            size = "4G";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            uuid = "205bd0a2-e61a-451d-84c3-2696a7a1e0f6";
            size = "100%";
            # LUKS2, unlocked by the TPM with a PIN (systemd-cryptenroll), or the
            # recovery key. The TPM only releases the key if PCR 7 matches: Secure Boot
            # on, and Limine signed with our key (system/boot.nix).
            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true; # TRIM; reveals which blocks are free
                crypttabExtraOpts = [ "tpm2-device=auto" ];
              };
              content = {
                type = "btrfs";
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = btrfsOpts;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = btrfsOpts;
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = btrfsOpts;
                  };
                };
              };
            };
          };
        };
      };
    };

    # Subvolumes share the whole partition's free space; none has a fixed size.
    # Subvolumes without a mountpoint appear as folders under /mnt/bulkfast.
    disko.devices.disk.data = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-WD_BLACK_SN7100_2TB_254846808262";
      destroy = false; # extra guard: disko's destroy stage skips this disk
      content = {
        type = "gpt";
        partitions.bulkfast = {
          uuid = "4d658c4d-b73c-499a-a81b-48ea69b858bb";
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [
              "--label"
              "bulkfast"
            ];
            mountpoint = "/mnt/bulkfast";
            mountOptions = dataOpts;
            subvolumes = {
              "Games" = { };
              "SteamLibrary" = { };
              "Disks" = { };
              "unreal-engine-bin" = { };
              "Unreal-Engine" = {
                mountpoint = "/opt/unreal-engine";
                mountOptions = dataOpts;
              };
              "personal" = {
                mountpoint = "/home/davidutz/personal";
                mountOptions = dataOpts;
              };
              "work" = {
                mountpoint = "/home/davidutz/work";
                mountOptions = dataOpts;
              };
            };
          };
        };
      };
    };

  };

  flake.nixosModules.desktop-btwDisko = {
    imports = [
      inputs.disko.nixosModules.disko
      self.diskoConfigurations.desktop-btw
    ];
  };
}
