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
      screenshotTestsDir = ./screenshot_tests;

      machineFiles = builtins.readDir machinesDir;
      machineNames = builtins.filter (name: lib.hasSuffix ".nix" name) (builtins.attrNames machineFiles);

      screenshotTestFiles = builtins.readDir screenshotTestsDir;
      screenshotTestNames = builtins.filter (name: lib.hasSuffix ".nix" name) (builtins.attrNames screenshotTestFiles);

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

      checks.${system} = builtins.listToAttrs (
        map (file: {
          name = builtins.replaceStrings [".nix"] [""] file;
          value = import (screenshotTestsDir + "/${file}") { inherit pkgs; };
        }) screenshotTestNames
      );
    };
}
