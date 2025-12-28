{ pkgs, systemModules }:

pkgs.testers.runNixOSTest {
  name = "GNOME_DESKTOP_LOADS";
  nodes.machine = {
    imports = systemModules.TEST_VM;
    virtualisation.memorySize = 4096;
  };
  testScript = builtins.readFile ./default.py;
}
