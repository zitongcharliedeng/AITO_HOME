{ pkgs, systemModules }:

pkgs.testers.runNixOSTest {
  name = "HOME_DIRECTORY_IS_GIT_REPO_AFTER_REBOOT";
  nodes.machine = {
    imports = systemModules.TEST_VM;
    virtualisation.memorySize = 1024;
  };
  testScript = builtins.readFile ./default.py;
}
