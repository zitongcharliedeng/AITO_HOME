{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hardware-configuration.nix
  ];

  # Hyper-V specific settings
  virtualisation.hypervGuest.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
