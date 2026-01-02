{ pkgs, systemModules, impermanence, self, disko, installerSystem }:

pkgs.testers.runNixOSTest {
  name = "WEB_FRONTEND_IS_RUNNING";

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

    print("\n--- USER OPENS BROWSER ---")
    machine.wait_for_open_port(8080)
    print("Web frontend port is open")

    print("\n--- USER SEES THE INTERFACE ---")
    result = machine.succeed("curl -s http://localhost:8080")
    print(f"Page content: {result[:200]}...")

    print("\n--- INTERFACE SHOWS AITO ---")
    assert "AITO" in result, "Interface should show AITO branding"
    print("AITO interface is displayed")

    print("\n=== WEB FRONTEND IS RUNNING ===")
  '';
}
