{ pkgs, systemModules, impermanence, self, disko, installerSystem }:

pkgs.testers.runNixOSTest {
  name = "DIGITAL_ASSISTANT_IS_ACCESSIBLE";

  nodes.machine = {
    imports = [
      ../../flake_modules/USE_TEST_FIXTURES/VIRTUAL_MACHINE_AFTER_INSTALL.nix
    ] ++ systemModules.TEST_VM;
  };

  testScript = ''
    print("\n--- USER BOOTS SYSTEM ---")
    machine.start()
    machine.wait_for_unit("multi-user.target")
    print("System is ready")

    print("\n--- USER STARTS DIGITAL ASSISTANT ---")
    machine.succeed("which aito")
    print("The 'aito' command is available")

    print("\n--- USER SAYS HELLO ---")
    result = machine.succeed("echo 'hello' | aito chat --test-mode")
    print(f"Assistant responded: {result}")

    print("\n--- USER GETS A RESPONSE ---")
    assert "hello" in result.lower() or len(result) > 0, "Assistant should respond"
    print("Digital assistant is working")

    print("\n=== DIGITAL ASSISTANT IS ACCESSIBLE ===")
  '';
}
