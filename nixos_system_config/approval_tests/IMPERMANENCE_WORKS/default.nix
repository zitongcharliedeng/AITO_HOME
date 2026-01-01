{ pkgs, systemModules, impermanence, self, disko }:

# PROPERTY TEST: Impermanence correctly persists/forgets data
#
# This tests the core property of your system:
# - Persisted paths survive reboot
# - Non-persisted paths are wiped on reboot
#
# This is critical for your PAI system where:
# - /persist/downloads (or similar) survives for cache
# - Everything else is fresh each boot

pkgs.testers.runNixOSTest {
  name = "IMPERMANENCE_WORKS";

  nodes.machine = { lib, modulesPath, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
    ] ++ systemModules.TEST_VM;

    virtualisation = {
      memorySize = 2048;
      cores = 2;
      # Need writable disk for persistence testing
      writableStore = true;
    };

    # Override disk config for VM testing
    disko.devices = lib.mkForce {};
    fileSystems = lib.mkForce {
      "/" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "mode=0755" "size=2G" ]; };
      "/nix" = { device = "/dev/vda"; fsType = "ext4"; neededForBoot = true; };
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # Create test file in PERSISTED directory
    machine.succeed("mkdir -p /persist/test")
    machine.succeed("echo 'should-survive' > /persist/test/persisted-file")

    # Create test file in NON-PERSISTED directory (tmpfs root)
    machine.succeed("echo 'should-vanish' > /tmp/ephemeral-file")

    # Verify both exist
    machine.succeed("cat /persist/test/persisted-file | grep should-survive")
    machine.succeed("cat /tmp/ephemeral-file | grep should-vanish")

    # Reboot
    machine.shutdown()
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # Property: Persisted file SURVIVES reboot
    machine.succeed("cat /persist/test/persisted-file | grep should-survive")

    # Property: Ephemeral file is GONE after reboot
    machine.fail("test -f /tmp/ephemeral-file")

    machine.log("SUCCESS: Impermanence working correctly")
  '';
}
