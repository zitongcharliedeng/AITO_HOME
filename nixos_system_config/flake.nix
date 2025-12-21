{
  description = "AITO_HOME";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;
      machinesDir = ./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_;

      machineFiles = builtins.readDir machinesDir;
      machineNames = builtins.filter (name: lib.hasSuffix ".nix" name) (builtins.attrNames machineFiles);

      mkSystem = file: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          (machinesDir + "/${file}")
          ./flake_modules/USE_SOFTWARE_CONFIG
          { nixpkgs.config.allowUnfree = true; }
        ];
      };
    in
    {
      nixosConfigurations = builtins.listToAttrs (
        map (file: {
          name = builtins.replaceStrings [".nix"] [""] file;
          value = mkSystem file;
        }) machineNames
      );

      checks.${system}.system_boots = pkgs.testers.nixosTest {
        name = "system-boots";

        nodes.machine = { ... }: {
          imports = [ ./flake_modules/USE_SOFTWARE_CONFIG ];

          fileSystems."/" = {
            device = "/dev/vda1";
            fsType = "ext4";
          };
        };

        testScript = ''
          machine.wait_for_unit("multi-user.target")

          with subtest("hostname is AITO"):
              result = machine.succeed("hostname")
              assert "AITO" in result, f"Expected hostname AITO, got {result}"

          with subtest("timezone is UTC"):
              result = machine.succeed("timedatectl show --property=Timezone --value")
              assert "UTC" in result, f"Expected UTC, got {result}"

          with subtest("user username exists"):
              machine.succeed("id username")

          with subtest("user username is in wheel group"):
              result = machine.succeed("groups username")
              assert "wheel" in result, f"Expected wheel group, got {result}"

          with subtest("flakes are enabled"):
              machine.succeed("nix --version")
              result = machine.succeed("nix show-config | grep experimental-features")
              assert "flakes" in result, f"Flakes not enabled: {result}"
        '';
      };
    };
}
