{ pkgs, lib, modulesPath, disko, ... }:

let
  availableMachineNames = lib.pipe (builtins.readDir ../flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_) [
    (lib.filterAttrs (n: _: lib.hasSuffix ".nix" n))
    builtins.attrNames
    (map (lib.removeSuffix ".nix"))
    (lib.filter (n: n != "TEST_VM"))
  ];

  machineList = lib.concatMapStringsSep "\n" (name: "  - ${name}") availableMachineNames;

  installScript = pkgs.writeShellScriptBin "INSTALL_SYSTEM" ''
    set -euo pipefail

    echo "=== AITO_HOME System Installer ==="
    echo ""

    if [[ $EUID -ne 0 ]]; then
      echo "ERROR: Must run as root (use sudo)"
      exit 1
    fi

    echo "Available machines:"
    ${lib.concatMapStringsSep "\n" (name: "echo \"  - ${name}\"") availableMachineNames}
    echo ""

    if [[ $# -lt 1 ]]; then
      echo "Usage: INSTALL_SYSTEM MACHINE_NAME"
      echo ""
      echo "Example: INSTALL_SYSTEM GPD_POCKET_4"
      exit 1
    fi

    MACHINE="$1"

    echo "Installing $MACHINE..."
    echo ""

    REPO_DIR="/tmp/AITO_HOME"

    if [[ ! -d "$REPO_DIR" ]]; then
      echo "Cloning configuration from GitHub..."
      git clone https://github.com/zitongcharliedeng/AITO_HOME.git "$REPO_DIR"
    fi

    cd "$REPO_DIR/nixos_system_config"

    echo "Running disko to partition disk..."
    nix --extra-experimental-features 'nix-command flakes' run .#disko -- --mode disko --flake ".#$MACHINE"

    echo "Installing NixOS..."
    nixos-install --flake ".#$MACHINE" --no-root-passwd

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

  environment.systemPackages = [
    pkgs.parted
    pkgs.dosfstools
    pkgs.e2fsprogs
    pkgs.git
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
${lib.concatMapStringsSep "\n" (name: "      - ${name}") availableMachineNames}

  '';
}
