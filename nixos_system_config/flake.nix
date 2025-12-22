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

      approvalTests = {
        FIRST_BOOT_SHOWS_LOGIN = import ./approval_tests/FIRST_BOOT_SHOWS_LOGIN { inherit pkgs; };
      };
    in
    {
      nixosConfigurations = {
        TEST_VM = lib.nixosSystem {
          inherit system;
          modules = [
            ./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_/TEST_VM.nix
            ./flake_modules/USE_SOFTWARE_CONFIG
            { nixpkgs.config.allowUnfree = true; }
          ];
        };
      };

      checks.${system} = approvalTests;

      packages.${system}.ALL_SCREENSHOTS = pkgs.runCommand "all-screenshots" {} ''
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: drv: ''
          mkdir -p $out/${name}
          cp ${drv}/*.png $out/${name}/
        '') approvalTests)}
      '';
    };
}
