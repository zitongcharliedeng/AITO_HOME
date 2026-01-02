{ lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  virtualisation.memorySize = 2048;
  virtualisation.cores = 2;
  virtualisation.writableStore = true;

  virtualisation.emptyDiskImages = [ 512 ];

  # Format the empty disk on first boot before mounting
  boot.initrd.postDeviceCommands = lib.mkBefore ''
    if ! blkid /dev/vdb | grep -q ext4; then
      ${pkgs.e2fsprogs}/bin/mkfs.ext4 -L persist /dev/vdb
    fi
  '';

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/persist";
    fsType = "ext4";
    neededForBoot = true;
  };

  disko.devices = lib.mkForce {};
  boot.loader.grub.enable = false;
}
