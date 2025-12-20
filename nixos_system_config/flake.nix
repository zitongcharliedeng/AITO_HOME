{
  description = "AITO_HOME";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      machinesDir = ./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_;

      machineFiles = builtins.readDir machinesDir;
      machineNames = builtins.filter (name: builtins.hasSuffix ".nix" name) (builtins.attrNames machineFiles);

      mkSystem = file: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          (machinesDir + "/${file}")
          ./flake_modules/USE_SOFTWARE_CONFIG
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
    };
}
