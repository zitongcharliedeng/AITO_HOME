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

      hardwareConfigs = lib.filterAttrs (n: _: lib.hasSuffix ".nix" n) (builtins.readDir ./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_);

      approvalTestDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./approval_tests);

      approvalTests = lib.mapAttrs (name: _:
        import ./approval_tests/${name} { inherit pkgs; }
      ) approvalTestDirs;
    in
    {
      nixosConfigurations = lib.mapAttrs' (file: _: {
        name = lib.removeSuffix ".nix" file;
        value = lib.nixosSystem {
          inherit system;
          modules = [
            (./flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_ + "/${file}")
            ./flake_modules/USE_SOFTWARE_CONFIG
            { nixpkgs.config.allowUnfree = true; }
          ];
        };
      }) hardwareConfigs;

      checks.${system} = approvalTests;

      packages.${system}.ALL_SCREENSHOTS = pkgs.runCommand "all-screenshots" {} ''
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: drv: ''
          mkdir -p $out/${name}
          cp ${drv}/*.png $out/${name}/
        '') approvalTests)}
      '';
    };
}
