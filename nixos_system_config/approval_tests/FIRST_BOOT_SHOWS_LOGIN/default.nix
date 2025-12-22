{ pkgs, systemModules }:

pkgs.testers.runNixOSTest {
  name = "FIRST_BOOT_SHOWS_LOGIN";
  nodes.machine = {
    imports = systemModules.TEST_VM;
    virtualisation.qemu.options = [ "-vga qxl" ];
    virtualisation.memorySize = 2048;
  };
  testScript = builtins.readFile ./default.py;
}
