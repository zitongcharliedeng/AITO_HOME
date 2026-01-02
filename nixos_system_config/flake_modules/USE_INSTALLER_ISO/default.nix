{ pkgs, lib, modulesPath, disko, ... }:

let
  availableMachineNames = lib.pipe (builtins.readDir ../USE_HARDWARE_CONFIG_FOR_MACHINE_) [
    (lib.filterAttrs (n: _: lib.hasSuffix ".nix" n))
    builtins.attrNames
    (map (lib.removeSuffix ".nix"))
    (lib.filter (n: n != "TEST_VM"))
  ];
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    disko.nixosModules.disko
  ];

  image.fileName = lib.mkForce "aito-installer.iso";

  environment.etc."aito-flake".source = ../..;

  environment.systemPackages = [
    pkgs.parted
    pkgs.dosfstools
    pkgs.e2fsprogs
    pkgs.git
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  disko.devices = lib.mkForce {};

  services.getty.helpLine = lib.mkForce ''

    === AITO_HOME Installer ===

    cd /etc/aito-flake
    sudo ./BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh --install /dev/DISK MACHINE_NAME

    Available machines:
${lib.concatMapStringsSep "\n" (name: "      - ${name}") availableMachineNames}

  '';
}
