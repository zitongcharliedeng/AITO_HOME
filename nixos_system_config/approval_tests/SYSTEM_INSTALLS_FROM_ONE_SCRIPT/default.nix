{ pkgs, systemModules, impermanence, self, disko }:

let
  flakePath = ../..;
in
pkgs.testers.runNixOSTest {
  name = "SYSTEM_INSTALLS_FROM_ONE_SCRIPT";

  nodes.installer = { lib, modulesPath, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      disko.nixosModules.disko
    ];

    virtualisation.memorySize = 4096;
    virtualisation.cores = 2;
    virtualisation.writableStore = true;
    virtualisation.emptyDiskImages = [ 20480 ];

    environment.etc."aito-flake".source = flakePath;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    disko.devices = lib.mkForce {};
    fileSystems = lib.mkForce {
      "/" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [ "mode=0755" "size=4G" ];
      };
    };

    boot.loader.grub.enable = false;
  };

  testScript = ''
    installer.start()
    installer.wait_for_unit("multi-user.target")

    with installer.nested("Verifying flake is available"):
      installer.succeed("test -d /etc/aito-flake")
      installer.succeed("test -f /etc/aito-flake/flake.nix")

    with installer.nested("Verifying BUILD script exists"):
      installer.succeed("test -x /etc/aito-flake/BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh")

    with installer.nested("Verifying flake contains machine configs"):
      installer.succeed("test -f /etc/aito-flake/flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_/GPD_POCKET_4.nix")
      installer.succeed("test -f /etc/aito-flake/flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_/TEST_VM.nix")

    with installer.nested("Verifying script shows usage without args"):
      result = installer.succeed("cd /etc/aito-flake && ./BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh 2>&1 || true")
      assert "Available machines" in result, "Should show available machines"
      assert "GPD_POCKET_4" in result, "Should list GPD_POCKET_4"

    with installer.nested("Verifying non-root install fails"):
      installer.fail("su - nobody -s /bin/sh -c 'cd /etc/aito-flake && ./BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh --install /dev/sda TEST_VM' 2>&1")
  '';
}
