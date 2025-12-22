{ pkgs }:

pkgs.testers.runNixOSTest {
  name = "FIRST_BOOT_SHOWS_LOGIN";
  nodes.machine = import ../TEST_MACHINE.nix;
  testScript = builtins.readFile ./default.py;
}
