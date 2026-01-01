{ pkgs, systemModules, impermanence, self, disko }:

# PROPERTY TEST: Expected services are running after boot
#
# This boots the actual TEST_VM configuration and verifies
# that runtime services are active.
#
# NixOS test framework IS appropriate here because:
# - We're testing runtime behavior (services running)
# - We boot the actual built config (no simulation)
# - It's hermetic and fast

pkgs.testers.runNixOSTest {
  name = "SERVICES_ARE_RUNNING";

  nodes.machine = { lib, modulesPath, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
    ] ++ systemModules.TEST_VM;

    # Override disk config for VM testing
    virtualisation = {
      memorySize = 2048;
      cores = 2;
    };

    # Disable disko in VM (use VM's virtual disk)
    disko.devices = lib.mkForce {};
    fileSystems = lib.mkForce {
      "/" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "mode=0755" ]; };
    };
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # Property: SSH service is running
    machine.wait_for_unit("sshd.service")
    machine.succeed("systemctl is-active sshd.service")

    # Property: Network manager is running
    machine.wait_for_unit("NetworkManager.service")
    machine.succeed("systemctl is-active NetworkManager.service")

    # Property: Expected user exists and can login
    machine.succeed("id username")

    # Property: Git is available (needed for home-as-repo)
    machine.succeed("which git")

    machine.log("SUCCESS: All expected services are running")
  '';
}
