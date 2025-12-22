{ pkgs, self }:

pkgs.testers.runNixOSTest {
  name = "first-boot-shows-login";

  nodes.machine = self.nixosConfigurations.TEST_VM.config;

  testScript = builtins.readFile ./FIRST_BOOT_SHOWS_LOGIN.py;
}
