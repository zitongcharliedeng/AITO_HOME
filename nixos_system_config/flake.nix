{
  description = "AITO_HOME - NixOS system config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      checks.${system} = {
        system-installs-from-flake = import ./tests/SYSTEM_INSTALLS_FROM_FLAKE.test.nix {
          inherit pkgs;
          inherit (nixpkgs) lib;
        };
      };

      nixosConfigurations.aito = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./flake_modules/USE_HARDWARE_CONFIG_
          ./flake_modules/USE_SOFTWARE_CONFIG
        ];
      };
    };
}
