{
  description = "AITO_HOME";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      machinesDir = ./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_;
      machineNames = builtins.attrNames (builtins.readDir machinesDir);

      mkSystem = machine: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          (machinesDir + "/${machine}")
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
