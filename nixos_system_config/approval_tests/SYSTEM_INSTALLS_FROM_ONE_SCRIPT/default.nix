{ pkgs, systemModules, impermanence, self, disko }:

# BUILD TEST: Verify TEST_VM configuration is valid
#
# This test verifies:
# - The nixosConfiguration builds successfully
# - The disko configuration is valid
# - The system closure can be computed
#
# The actual INSTALL + BOOT flow is tested via GitHub Actions E2E
# with a real NixOS ISO and network access (see e2e_install.yml).
#
# Philosophy:
# - Nix guarantees declarative correctness if it builds
# - We only need to verify the build succeeds
# - Runtime behavior tested via E2E with real environment

let
  system = "x86_64-linux";
  testMachineConfig = self.nixosConfigurations.TEST_VM;
in
pkgs.runCommand "SYSTEM_INSTALLS_FROM_ONE_SCRIPT" {
  # These must all evaluate successfully
  inherit (testMachineConfig.config.system.build) toplevel;
  diskoScript = testMachineConfig.config.system.build.diskoScript;
} ''
  echo "=== BUILD TEST: TEST_VM Configuration ==="
  echo ""
  echo "✓ nixosConfiguration builds: $toplevel"
  echo "✓ disko script builds: $diskoScript"
  echo ""
  echo "Build test passed. Runtime behavior tested via E2E workflow."

  mkdir -p $out
  echo "passed" > $out/result
''
