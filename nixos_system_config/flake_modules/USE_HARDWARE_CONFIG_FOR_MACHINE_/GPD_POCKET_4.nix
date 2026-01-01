{ modulesPath, nixos-hardware, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    nixos-hardware.nixosModules.gpd-pocket-4
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [ "amdgpu.pcie_gen_cap=0x40000" ];

  hardware.cpu.amd.updateMicrocode = true;

  disko.devices.disk.main.device = "/dev/nvme0n1";
}
