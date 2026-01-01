{ modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  # Disko manages all filesystems (root is tmpfs, /nix and /boot are partitions)
  # Boot loader uses systemd-boot on EFI
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Target disk for installation
  # In test: installer VM boots from /dev/vda, installs to /dev/vdb
  # Then boots the installed system directly from /dev/vdb as /dev/vda
  disko.devices.disk.main.device = "/dev/vdb";
}
