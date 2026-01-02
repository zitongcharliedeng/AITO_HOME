{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  virtualisation.memorySize = 2048;
  virtualisation.cores = 2;
  virtualisation.emptyDiskImages = [ 512 ];

  disko.devices = lib.mkForce {};

  fileSystems."/persist" = {
    device = "/dev/vdb";
    fsType = "ext4";
    neededForBoot = true;
    autoFormat = true;
  };

  boot.loader.grub.enable = false;
}
