{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  virtualisation.memorySize = 2048;
  virtualisation.cores = 2;
  virtualisation.writableStore = true;

  disko.devices = lib.mkForce {};
  boot.loader.grub.enable = false;

  fileSystems."/persist" = lib.mkForce {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "defaults" "size=256M" "mode=755" ];
    neededForBoot = true;
  };
}
