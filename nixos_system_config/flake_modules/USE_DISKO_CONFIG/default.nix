# Declarative disk partitioning with disko
# GPT layout: EFI (512M) + nix (remaining)
#
# The device defaults to /dev/vda but can be overridden in hardware config:
#   disko.devices.disk.main.device = "/dev/nvme0n1";
#
# Uses tmpfs for / with impermanence - only /nix and /boot are real partitions
# Everything else is ephemeral and rebuilt on boot
#
# Uses filesystem labels so the system boots regardless of device naming
# (e.g., install on /dev/vdb, boot from /dev/vda)

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              label = "AITO_BOOT";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            nix = {
              size = "100%";
              label = "AITO_NIX";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [ "defaults" "size=2G" "mode=755" ];
      };
    };
  };

  # Persist directory lives inside /nix (which is persistent)
  fileSystems."/persist" = {
    device = "/nix/persist";
    options = [ "bind" ];
    neededForBoot = true;
  };
}
