{ pkgs, systemModules, impermanence, self, disko }:

pkgs.testers.runNixOSTest {
  name = "IMPERMANENCE_WORKS";

  nodes.machine = {
    imports = [
      ../../flake_modules/USE_TEST_FIXTURES/VIRTUAL_MACHINE_WITH_PERSISTENCE.nix
    ] ++ systemModules.TEST_VM;
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    machine.succeed("mkdir -p /persist/test")
    machine.succeed("echo 'persisted' > /persist/test/file")
    machine.succeed("echo 'ephemeral' > /tmp/file")

    machine.shutdown()
    machine.start()
    machine.wait_for_unit("multi-user.target")

    machine.succeed("cat /persist/test/file | grep persisted")
    machine.fail("test -f /tmp/file")
  '';
}
