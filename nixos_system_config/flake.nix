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

      nixFilesIn = dir: lib.filterAttrs (n: _: lib.hasSuffix ".nix" n) (builtins.readDir dir);

      approvalTests = lib.mapAttrs' (file: _: {
        name = lib.removeSuffix ".nix" file;
        value = import (./approval_tests + "/${file}") { inherit pkgs self; };
      }) (nixFilesIn ./approval_tests);

      mkSystem = file: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          (./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_ + "/${file}")
          ./flake_modules/USE_SOFTWARE_CONFIG
          { nixpkgs.config.allowUnfree = true; }
        ];
      };
    in
    {
      nixosConfigurations = lib.mapAttrs' (file: _: {
        name = lib.removeSuffix ".nix" file;
        value = mkSystem file;
      }) (nixFilesIn ./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_);

      checks.${system} = approvalTests;

      packages.${system}.RUN_APPROVAL_TESTS = pkgs.callPackage ./RUN_APPROVAL_TESTS.nix {
        inherit approvalTests;
      };
    };
}
