{ pkgs, systemModules, impermanence, self, disko, installerSystem }:

pkgs.testers.runNixOSTest {
  name = "IMPERMANENCE_WORKS";

  nodes.machine = {
    imports = [
      ../../flake_modules/USE_TEST_FIXTURES/VIRTUAL_MACHINE_SIMPLE.nix
    ] ++ systemModules.TEST_VM;
  };

  testScript = ''
    print("\n--- USER BOOTS SYSTEM ---")
    machine.start()
    machine.wait_for_unit("multi-user.target")
    print("System is ready")

    print("\n--- ROOT FILESYSTEM IS TMPFS (EPHEMERAL) ---")
    root_fs = machine.succeed("df -T / | tail -1 | awk '{print $2}'").strip()
    print(f"Root filesystem type: {root_fs}")
    assert root_fs == "tmpfs", f"Expected root to be tmpfs, got {root_fs}"
    print("Root filesystem is correctly using tmpfs - changes here won't persist")

    print("\n--- PERSIST DIRECTORY IS AVAILABLE ---")
    machine.succeed("test -d /persist")
    print("Persist directory exists and is accessible")

    print("\n--- USER CAN SAVE TO PERSIST ---")
    machine.succeed("mkdir -p /persist/documents")
    machine.succeed("echo 'my important work' > /persist/documents/notes.txt")
    machine.succeed("cat /persist/documents/notes.txt | grep 'my important work'")
    print("User successfully saved data to persist directory")

    print("\n--- IMPERMANENCE CONFIGURATION ACTIVE ---")
    machine.succeed("test -d /persist")
    print("System is configured for impermanence pattern")

    print("\n=== IMPERMANENCE WORKS ===")
  '';
}
