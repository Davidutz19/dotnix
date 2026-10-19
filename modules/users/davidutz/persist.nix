# Home state that survives the reboot. On hosts with nixosModules.impermanence, /home
# is wiped with `/` on every boot, and only the paths listed in `davidutz.persist`
# come back, bind-mounted from /persist/home/davidutz.
#
# Each file lists the state of the thing it configures, next to it:
#   davidutz.persist.directories = [ ".config/discord" ];
# Paths are relative to the home directory. An entry can also be an attrset with
# preservation's options, for example `{ directory = ".ssh"; mode = "0700"; }`.
#
# Files are bind-mounted, so a program that saves by writing a new file and renaming
# it over the old one fails with EBUSY. Put such state in a preserved directory instead
# (zsh's history is in ~/.local/share/zsh for that reason).
#
# Something lost its settings after a reboot? Find where it writes
# (`find ~ -xdev -newer /etc/os-release -not -path '*/.cache/*'`) and list the path in
# the file that configures it. Machines without impermanence ignore the list.
{
  flake.nixosModules.davidutz =
    {
      config,
      lib,
      options,
      ...
    }:
    {
      config = lib.optionalAttrs (options ? preservation) {
        preservation.preserveAt."/persist".users.davidutz = {
          inherit (config.hm.davidutz.persist) directories files;
        };
      };
    };

  flake.homeModules.davidutz =
    { lib, ... }:
    let
      paths =
        description:
        lib.mkOption {
          type = with lib.types; listOf (either str (attrsOf anything));
          default = [ ];
          inherit description;
        };
    in
    {
      options.davidutz.persist = {
        directories = paths "Directories under the home directory that survive a reboot.";
        files = paths "Files under the home directory that survive a reboot.";
      };

      config.davidutz.persist.directories = [
        "Documents"
        "Downloads"
        "Pictures"
        "Videos"
        "Games"
        "GameServers"
        "archive"

        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".gnupg";
          mode = "0700";
        }
        ".pki" # NSS certificate database (browsers, Electron apps)
        ".kube" # kubectl contexts
        ".config/sops" # age keys
        ".config/dconf" # GSettings written by apps
        ".local/share/keyrings" # gnome-keyring
        ".local/share/Trash"
        # Desktop entries and icons that Steam, Lutris and Heroic create for games.
        ".local/share/applications"
        ".local/share/icons"
        ".local/state/wireplumber" # default devices and volumes
      ];
      config.davidutz.persist.files = [ ".npmrc" ]; # the local verdaccio registry token
    };
}
