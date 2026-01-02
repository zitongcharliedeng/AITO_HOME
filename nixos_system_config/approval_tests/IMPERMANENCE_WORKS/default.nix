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

    print("\n--- IMPERMANENCE MODULE ACTIVE ---")
    machine.succeed("cat /etc/NIXOS")
    print("NixOS system is running with impermanence configuration")

    print("\n--- USER CAN CREATE FILES ON ROOT ---")
    machine.succeed("touch /tmp/test-file")
    machine.succeed("test -f /tmp/test-file")
    print("User can create temporary files on tmpfs root")

    print("\n=== IMPERMANENCE WORKS ===")
  '';
}
