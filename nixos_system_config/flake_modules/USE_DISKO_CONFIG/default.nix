{ lib, ... }: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = lib.mkDefault "/dev/vda";
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

  fileSystems."/persist" = {
    device = "/nix/persist";
    options = [ "bind" ];
    neededForBoot = true;
  };
}
