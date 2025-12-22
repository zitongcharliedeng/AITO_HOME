{ pkgs, machineModules }:

pkgs.testers.runNixOSTest {
  name = "FIRST_BOOT_SHOWS_LOGIN";
  nodes.machine = { ... }: { imports = machineModules.TEST_VM; };
  testScript = builtins.readFile ./default.py;
}
