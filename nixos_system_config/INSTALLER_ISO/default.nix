{ pkgs, lib, modulesPath, disko, self, nixosConfigurations, ... }:

let
  allMachineNames = lib.pipe (builtins.readDir ../flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_) [
    (lib.filterAttrs (n: _: lib.hasSuffix ".nix" n))
    builtins.attrNames
    (map (lib.removeSuffix ".nix"))
  ];

  displayMachineNames = lib.filter (n: n != "TEST_VM") allMachineNames;

  machineDiskoScripts = lib.genAttrs allMachineNames (name:
    nixosConfigurations.${name}.config.system.build.diskoScript
  );

  machineToplevels = lib.genAttrs allMachineNames (name:
    nixosConfigurations.${name}.config.system.build.toplevel
  );

  installScript = pkgs.writeShellScriptBin "INSTALL_SYSTEM" ''
    set -euo pipefail

    echo "=== AITO_HOME System Installer ==="
    echo ""

    if [[ $EUID -ne 0 ]]; then
      echo "ERROR: Must run as root (use sudo)"
      exit 1
    fi

    echo "Available machines:"
    ${lib.concatMapStringsSep "\n" (name: "echo \"  - ${name}\"") displayMachineNames}
    echo ""

    if [[ $# -lt 1 ]]; then
      echo "Usage: INSTALL_SYSTEM MACHINE_NAME"
      echo ""
      echo "Example: INSTALL_SYSTEM ${lib.head displayMachineNames}"
      exit 1
    fi

    MACHINE="$1"

    case "$MACHINE" in
      ${lib.concatMapStringsSep "\n" (name: ''
        ${name})
          DISKO_SCRIPT="${machineDiskoScripts.${name}}"
          SYSTEM_TOPLEVEL="${machineToplevels.${name}}"
          ;;'') allMachineNames}
      *)
        echo "ERROR: Unknown machine '$MACHINE'"
        echo "Available: ${lib.concatStringsSep ", " displayMachineNames}"
        exit 1
        ;;
    esac

    echo "Installing $MACHINE..."
    echo ""

    echo "Running disko to partition disk..."
    $DISKO_SCRIPT

    echo "Installing NixOS..."
    nixos-install --system "$SYSTEM_TOPLEVEL" --no-root-passwd

    echo ""
    echo "=== Installation complete! ==="
    echo "You can now reboot into your new system."
  '';
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    disko.nixosModules.disko
  ];

  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkForce false;

  environment.systemPackages = [
    pkgs.parted
    pkgs.dosfstools
    pkgs.e2fsprogs
    installScript
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.kernelParams = [ "console=ttyS0,115200" "console=tty0" ];

  disko.devices = lib.mkForce {};

  system.activationScripts.installScriptInHome = ''
    mkdir -p /home/nixos
    ln -sf ${installScript}/bin/INSTALL_SYSTEM /home/nixos/INSTALL_SYSTEM.sh
    chown -R nixos:users /home/nixos || true
  '';

  services.getty.helpLine = lib.mkForce ''

    === AITO_HOME Installer ===

    Run: ./INSTALL_SYSTEM.sh MACHINE_NAME

    Available machines:
${lib.concatMapStringsSep "\n" (name: "      - ${name}") displayMachineNames}

  '';
}
