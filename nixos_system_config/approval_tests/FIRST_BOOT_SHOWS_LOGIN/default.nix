{ pkgs, systemModules }:

pkgs.testers.runNixOSTest {
  name = "FIRST_BOOT_SHOWS_LOGIN";
  nodes.machine = {
    imports = systemModules.TEST_VM;
    # Use virtio-gpu-gl-pci for 3D acceleration with egl-headless display
    # This enables virgl which can use llvmpipe on the host for software 3D
    virtualisation.qemu.options = [
      "-vga none"
      "-device virtio-gpu-gl-pci"
      "-display egl-headless"
    ];
    virtualisation.memorySize = 2048;
  };
  testScript = builtins.readFile ./default.py;
}
