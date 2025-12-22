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

      machineFiles = lib.filterAttrs (n: _: lib.hasSuffix ".nix" n)
        (builtins.readDir ./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_);

      approvalTestFiles = lib.filterAttrs (n: _: lib.hasSuffix ".nix" n)
        (builtins.readDir ./approval_tests);

      mkSystem = file: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          (./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_ + "/${file}")
          ./flake_modules/USE_SOFTWARE_CONFIG
        ];
      };
    in
    {
      softwareModules = [ ./flake_modules/USE_SOFTWARE_CONFIG ];

      nixosConfigurations = lib.mapAttrs' (file: _: {
        name = lib.removeSuffix ".nix" file;
        value = mkSystem file;
      }) machineFiles;

      checks.${system} = lib.mapAttrs' (file: _: {
        name = lib.removeSuffix ".nix" file;
        value = import (./approval_tests + "/${file}") { inherit pkgs self; };
      }) approvalTestFiles;
    };
}
