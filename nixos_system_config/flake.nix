{
  description = "AITO_HOME";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, pre-commit-hooks, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      lib = nixpkgs.lib;

      hardwareConfigs = lib.filterAttrs (n: _: lib.hasSuffix ".nix" n) (builtins.readDir ./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_);

      systemModules = lib.mapAttrs' (file: _: {
        name = lib.removeSuffix ".nix" file;
        value = [
          (./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_ + "/${file}")
          ./flake_modules/USE_SOFTWARE_CONFIG
        ];
      }) hardwareConfigs;

      approvalTestDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./approval_tests);

      approvalTests = lib.mapAttrs (name: _:
        import ./approval_tests/${name} { inherit pkgs systemModules; }
      ) approvalTestDirs;

      preCommitCheck = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          flake-check = {
            enable = true;
            name = "nix-flake-check";
            entry = "${pkgs.nix}/bin/nix --extra-experimental-features 'nix-command flakes' flake check";
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

      checks.${system} = approvalTests // {
        pre-commit = preCommitCheck;
      };

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
