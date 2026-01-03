{ pkgs, lib, modulesPath, disko, self, ... }:

let
  availableMachineNames = lib.pipe (builtins.readDir ../flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_) [
    (lib.filterAttrs (n: _: lib.hasSuffix ".nix" n))
    builtins.attrNames
    (map (lib.removeSuffix ".nix"))
    (lib.filter (n: n != "TEST_VM"))
  ];

  flakeSource = self;

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

    echo "Checking network connectivity..."
    if ! ping -c 1 -W 5 cache.nixos.org &>/dev/null; then
      echo ""
      echo "No internet connection detected."
      echo "Internet is required to download NixOS packages."
      echo ""
      echo "Connect via:"
      echo "  - Ethernet: Should auto-connect"
      echo "  - WiFi: Run 'nmtui' to connect"
      echo ""
      echo "Then run this script again."
      exit 1
    fi
    echo "Network OK"
    echo ""

    echo "Installing $MACHINE..."
    echo ""

    FLAKE_DIR="${flakeSource}"

    echo "Running disko to partition disk..."
    nix --extra-experimental-features 'nix-command flakes' run path:$FLAKE_DIR#disko -- --mode disko --flake "path:$FLAKE_DIR#$MACHINE"

    echo "Installing NixOS..."
    nixos-install --flake "path:$FLAKE_DIR#$MACHINE" --no-root-passwd

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
${lib.concatMapStringsSep "\n" (name: "      - ${name}") availableMachineNames}

  '';
}
