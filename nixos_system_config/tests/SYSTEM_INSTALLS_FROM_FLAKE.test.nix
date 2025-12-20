# SYSTEM_INSTALLS_FROM_FLAKE.test.nix
#
# The system boots successfully from this flake.
# This is the most basic test - if this fails, nothing else matters.

{ pkgs, lib, ... }:

pkgs.testers.runNixOSTest {
  name = "system-installs-from-flake";

  nodes.machine = { config, pkgs, ... }: {
    imports = [
      ../flake_modules/USE_HARDWARE_CONFIG_
      ../flake_modules/USE_SOFTWARE_CONFIG
    ];

    # Minimal VM settings for test
    virtualisation.memorySize = 2048;
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("echo 'System booted successfully'")
    machine.screenshot("system_booted")
  '';
}
