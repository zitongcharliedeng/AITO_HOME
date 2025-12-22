{ pkgs, self }:

pkgs.testers.runNixOSTest {
  name = "first-boot-shows-login";

  nodes.machine = { ... }: {
    # Import the SAME modules used by real machines
    imports = self.softwareModules;

    # VM-specific: filesystem for virtual disk
    fileSystems."/" = {
      device = "/dev/vda1";
      fsType = "ext4";
    };
  };

  testScript = builtins.readFile ./FIRST_BOOT_SHOWS_LOGIN.py;
}
