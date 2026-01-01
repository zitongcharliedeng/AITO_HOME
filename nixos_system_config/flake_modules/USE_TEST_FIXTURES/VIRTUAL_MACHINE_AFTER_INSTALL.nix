{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  virtualisation.memorySize = 2048;
  virtualisation.cores = 2;

  disko.devices = lib.mkForce {};

  fileSystems = lib.mkForce {
    "/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "mode=0755" "size=2G" ];
    };
  };
}
