{
  description = "AITO_HOME";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      machinesDir = ./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_;

      allFiles = builtins.readDir machinesDir;
      nixFiles = builtins.filter (name: builtins.match ".*\\.nix$" name != null) (builtins.attrNames allFiles);
      machineNames = map (name: builtins.replaceStrings [".nix"] [""] name) nixFiles;

      mkSystem = machine: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          (machinesDir + "/${machine}.nix")
          ./flake_modules/USE_SOFTWARE_CONFIG
        ];
      };
    in
    {
      nixosConfigurations = builtins.listToAttrs (
        map (name: { inherit name; value = mkSystem name; }) machineNames
      );
    };
}
