{ pkgs, self }:

pkgs.testers.runNixOSTest {
  name = "first-boot-shows-login";

  nodes.machine = { ... }: {
    imports = [
      ../flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_/TEST_VM.nix
      ../flake_modules/USE_SOFTWARE_CONFIG
    ];
  };

  testScript = builtins.readFile ./FIRST_BOOT_SHOWS_LOGIN.py;
}
