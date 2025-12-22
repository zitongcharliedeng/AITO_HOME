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
      approvalTestsDir = ./approval_tests;

      # Shared software config - used by both real machines and tests
      softwareModules = [
        ./flake_modules/USE_SOFTWARE_CONFIG
        { nixpkgs.config.allowUnfree = true; }
      ];

      machineFiles = builtins.readDir machinesDir;
      machineNames = builtins.filter (name: lib.hasSuffix ".nix" name) (builtins.attrNames machineFiles);

      approvalTestFiles = builtins.readDir approvalTestsDir;
      approvalTestNames = builtins.filter (name: lib.hasSuffix ".nix" name) (builtins.attrNames approvalTestFiles);

      mkSystem = file: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ (machinesDir + "/${file}") ] ++ softwareModules;
      };
    in
    {
      # Shared modules - tests import these directly
      inherit softwareModules;

      nixosConfigurations = builtins.listToAttrs (
        map (file: {
          name = builtins.replaceStrings [".nix"] [""] file;
          value = mkSystem file;
        }) machineNames
      );

      checks.${system} = builtins.listToAttrs (
        map (file: {
          name = builtins.replaceStrings [".nix"] [""] file;
          value = import (approvalTestsDir + "/${file}") { inherit pkgs self; };
        }) approvalTestNames
      );
    };
}
