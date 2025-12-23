{ pkgs, systemModules }:

pkgs.testers.runNixOSTest {
  name = "FIRST_BOOT_SHOWS_LOGIN";
  nodes.machine = {
    imports = systemModules.TEST_VM;
    virtualisation.graphics = true;
    virtualisation.qemu.options = [ "-vga virtio" ];
    virtualisation.memorySize = 2048;
  };
  testScript = builtins.readFile ./default.py;
}
