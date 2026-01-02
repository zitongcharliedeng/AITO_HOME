{ pkgs, systemModules, impermanence, self, disko, installerSystem }:

pkgs.testers.runNixOSTest {
  name = "IMPERMANENCE_WORKS";

  nodes.machine = {
    imports = [
      ../../flake_modules/USE_TEST_FIXTURES/VIRTUAL_MACHINE_WITH_PERSISTENCE.nix
    ] ++ systemModules.TEST_VM;
  };

  testScript = ''
    print("\n--- USER BOOTS SYSTEM ---")
    machine.start()
    machine.wait_for_unit("multi-user.target")
    print("System is ready")

    print("\n--- USER SAVES IMPORTANT FILE ---")
    machine.succeed("mkdir -p /persist/documents")
    machine.succeed("echo 'my important work' > /persist/documents/notes.txt")
    print("User saved notes.txt to persist directory")

    print("\n--- USER CREATES TEMPORARY FILE ---")
    machine.succeed("echo 'scratch data' > /tmp/scratch.txt")
    print("User created temporary scratch file")

    print("\n--- SYSTEM REBOOTS ---")
    machine.shutdown()
    machine.start()
    machine.wait_for_unit("multi-user.target")
    print("System came back up")

    print("\n--- USER FINDS IMPORTANT FILE ---")
    machine.succeed("cat /persist/documents/notes.txt | grep 'my important work'")
    print("User's important work survived the reboot")

    print("\n--- TEMPORARY FILE IS GONE ---")
    machine.fail("test -f /tmp/scratch.txt")
    print("Temporary files were cleaned up as expected")

    print("\n=== IMPERMANENCE WORKS ===")
  '';
}
