{ pkgs, ... }:

pkgs.testers.runNixOSTest {
  name = "first-boot-shows-login";

  nodes.machine = { ... }: {
    imports = [ ../flake_modules/USE_SOFTWARE_CONFIG ];

    users.mutableUsers = false;

    fileSystems."/" = {
      device = "/dev/vda1";
      fsType = "ext4";
    };
  };

  testScript = builtins.readFile ./FIRST_BOOT_SHOWS_LOGIN.py;
}
