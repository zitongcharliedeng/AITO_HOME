{ pkgs, ... }:

pkgs.testers.runNixOSTest {
  name = "system-boots";

  nodes.machine = { ... }: {
    imports = [ ../flake_modules/USE_SOFTWARE_CONFIG ];

    fileSystems."/" = {
      device = "/dev/vda1";
      fsType = "ext4";
    };
  };

  testScript = builtins.readFile ./SYSTEM_BOOTS.py;
}
