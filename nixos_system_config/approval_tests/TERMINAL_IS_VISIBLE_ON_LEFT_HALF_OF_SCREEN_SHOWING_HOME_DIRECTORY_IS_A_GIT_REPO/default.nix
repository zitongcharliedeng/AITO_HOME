{ pkgs, systemModules }:

pkgs.testers.runNixOSTest {
  name = "TERMINAL_IS_VISIBLE_ON_LEFT_HALF_OF_SCREEN_SHOWING_HOME_DIRECTORY_IS_A_GIT_REPO";
  nodes.machine = {
    imports = systemModules.TEST_VM;
    # virtio-gpu-pci provides DRM device for niri (software rendering in guest)
    # Keep default VGA for QEMU screendump to capture output
    virtualisation.qemu.options = [
      "-device virtio-gpu-pci"
    ];
    virtualisation.memorySize = 2048;
  };
  testScript = builtins.readFile ./default.py;
}
