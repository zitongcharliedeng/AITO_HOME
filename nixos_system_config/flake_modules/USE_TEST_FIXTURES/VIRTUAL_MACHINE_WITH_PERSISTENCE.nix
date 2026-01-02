{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  virtualisation.memorySize = 2048;
  virtualisation.cores = 2;
  virtualisation.writableStore = true;

  virtualisation.emptyDiskImages = [ 512 ];

  fileSystems."/persist" = {
    device = "/dev/vdb";
    fsType = "ext4";
    neededForBoot = true;
    autoFormat = true;
  };

  disko.devices = lib.mkForce {};
  boot.loader.grub.enable = false;
}
