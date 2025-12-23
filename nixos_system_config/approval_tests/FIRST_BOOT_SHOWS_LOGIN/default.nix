{ pkgs, systemModules }:

pkgs.testers.runNixOSTest {
  name = "FIRST_BOOT_SHOWS_LOGIN";
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
