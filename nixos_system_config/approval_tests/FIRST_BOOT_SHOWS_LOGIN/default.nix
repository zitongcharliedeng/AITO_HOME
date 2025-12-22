{ pkgs, systemModules }:

pkgs.testers.runNixOSTest {
  name = "FIRST_BOOT_SHOWS_LOGIN";
  nodes.machine = { imports = systemModules.TEST_VM; };
  testScript = builtins.readFile ./default.py;
}
