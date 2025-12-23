{ pkgs, systemModules }:

pkgs.testers.runNixOSTest {
  name = "TERMINAL_IS_VISIBLE_ON_LEFT_HALF_OF_SCREEN_SHOWING_HOME_DIRECTORY_IS_A_GIT_REPO";
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
