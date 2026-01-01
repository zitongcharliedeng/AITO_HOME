{ pkgs, systemModules, impermanence }:

pkgs.testers.runNixOSTest {
  name = "HOME_DIRECTORY_IS_GIT_REPO_AFTER_REBOOT";
  nodes.machine = { config, lib, pkgs, ... }: {
    imports = systemModules.TEST_VM;

    # Use real boot loader for proper initrd execution
    virtualisation.useBootLoader = true;

    # Override systemd-boot (EFI) with GRUB (legacy) for test VM
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.grub.enable = lib.mkForce true;
    boot.loader.grub.device = lib.mkForce "/dev/vda";
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

    # Persistent disk for /persist (survives reboot)
    virtualisation.emptyDiskImages = [ 1024 ];

    # Ensure ext4 is fully supported in initrd (kernel module + mkfs tool)
    boot.initrd.supportedFilesystems = [ "ext4" ];

    fileSystems."/persist" = {
      device = "/dev/vdb";
      fsType = "ext4";
      autoFormat = true;
      neededForBoot = true;
    };

    virtualisation.memorySize = 4096;
  };
  testScript = builtins.readFile ./default.py;
}
