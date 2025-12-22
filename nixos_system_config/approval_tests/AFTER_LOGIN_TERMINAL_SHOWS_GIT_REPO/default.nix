{ pkgs, systemModules }:

pkgs.testers.runNixOSTest {
  name = "AFTER_LOGIN_TERMINAL_SHOWS_GIT_REPO";
  nodes.machine = {
    imports = systemModules.TEST_VM;
    virtualisation.qemu.options = [ "-vga virtio" ];
  };
  testScript = builtins.readFile ./default.py;
}
