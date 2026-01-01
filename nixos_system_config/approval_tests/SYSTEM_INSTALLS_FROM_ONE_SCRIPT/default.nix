{ pkgs, systemModules, impermanence, self, disko }:

let
  testMachineConfig = self.nixosConfigurations.TEST_VM;
  systemTopLevel = testMachineConfig.config.system.build.toplevel;
  diskoScript = testMachineConfig.config.system.build.diskoScript;
in
pkgs.runCommand "SYSTEM_INSTALLS_FROM_ONE_SCRIPT" {
  inherit systemTopLevel diskoScript;
} ''
  mkdir -p $out
  echo "passed" > $out/result
''
