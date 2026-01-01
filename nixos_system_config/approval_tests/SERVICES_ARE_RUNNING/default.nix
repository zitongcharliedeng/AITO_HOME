{ pkgs, systemModules, impermanence, self, disko }:

pkgs.testers.runNixOSTest {
  name = "SERVICES_ARE_RUNNING";

  nodes.machine = {
    imports = [
      ../../flake_modules/USE_TEST_FIXTURES/VIRTUAL_MACHINE_AFTER_INSTALL.nix
    ] ++ systemModules.TEST_VM;
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    machine.wait_for_unit("sshd.service")
    machine.wait_for_unit("NetworkManager.service")
    machine.succeed("id username")
    machine.succeed("which git")
  '';
}
