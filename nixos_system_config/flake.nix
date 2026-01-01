{
  description = "AITO_HOME";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, pre-commit-hooks, disko, impermanence, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      lib = nixpkgs.lib;

      hardwareConfigs = lib.filterAttrs (n: _: lib.hasSuffix ".nix" n) (builtins.readDir ./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_);

      # Production system configuration
      # Includes impermanence - tests must provide /persist filesystem
      systemModules = lib.mapAttrs' (file: _: {
        name = lib.removeSuffix ".nix" file;
        value = [
          (./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_ + "/${file}")
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.username = import ./flake_modules/USE_HOME_CONFIG;
          }
          ./flake_modules/USE_SOFTWARE_CONFIG
          impermanence.nixosModules.impermanence
          ./flake_modules/USE_SOFTWARE_CONFIG/default_modules/USE_IMPERMANENCE
        ];
      }) hardwareConfigs;

      # Disko modules for fresh installs (partitions disk)
      diskoModules = [
        disko.nixosModules.disko
        ./flake_modules/USE_DISKO_CONFIG
      ];

      approvalTestDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./approval_tests);

      approvalTests = lib.mapAttrs (name: _:
        import ./approval_tests/${name} { inherit pkgs systemModules impermanence; }
      ) approvalTestDirs;

      preCommitCheck = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          flake-check = {
            enable = true;
            name = "nix-flake-check";
            entry = "${pkgs.nix}/bin/nix --extra-experimental-features 'nix-command flakes' flake check --no-build ./nixos_system_config";
            pass_filenames = false;
            stages = [ "pre-commit" ];
          };
        };
      };
    in
    {
      nixosConfigurations = lib.mapAttrs (name: modules:
        lib.nixosSystem { inherit system modules; }
      ) systemModules;

      # Configurations with disko for fresh installs
      # Usage: disko --flake .#install-MACHINE_NAME --mode disko
      diskoConfigurations = lib.mapAttrs (name: modules:
        lib.nixosSystem {
          inherit system;
          modules = modules ++ diskoModules;
        }
      ) systemModules;

      checks.${system} = approvalTests;

      packages.${system}.ALL_SCREENSHOTS = pkgs.runCommand "all-screenshots" {} ''
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: drv: ''
          mkdir -p $out/${name}
          cp ${drv}/*.png $out/${name}/
        '') approvalTests)}
      '';

      devShells.${system}.default = pkgs.mkShell {
        inherit (preCommitCheck) shellHook;
      };
    };
}
