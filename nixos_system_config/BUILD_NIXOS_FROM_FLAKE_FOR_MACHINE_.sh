#!/usr/bin/env bash
# BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh
#
# The ONE script for AITO NixOS.
#
# Fresh install (from NixOS ISO):
#   git clone https://github.com/zitongcharliedeng/AITO_HOME
#   cd AITO_HOME/nixos_system_config
#   sudo ./BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh --install /dev/sda MY_MACHINE
#
# Update existing system:
#   ./BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh MY_MACHINE

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACHINES_DIR="$SCRIPT_DIR/flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_"

list_machines() {
    for f in "$MACHINES_DIR"/*.nix; do
        [[ -f "$f" ]] && basename "$f" .nix
    done
}

validate_machine_name() {
    [[ "$1" =~ ^[A-Z][A-Z0-9_]*$ ]]
}

usage() {
    echo "Usage:"
    echo "  Fresh install:  sudo $0 --install /dev/DISK MACHINE_NAME"
    echo "  Update system:  $0 MACHINE_NAME"
    echo ""
    echo "Available machines:"
    list_machines
    echo ""
    echo "Machine names must be SCREAMING_SNAKE_CASE (e.g., MY_LAPTOP)"
}

# Parse arguments
INSTALL_MODE=false
TARGET_DISK=""
MACHINE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --install)
            INSTALL_MODE=true
            TARGET_DISK="${2:-}"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            MACHINE="$1"
            shift
            ;;
    esac
done

# Validate arguments
if [[ -z "$MACHINE" ]]; then
    usage
    exit 1
fi

if ! validate_machine_name "$MACHINE"; then
    echo "Error: Machine name must be SCREAMING_SNAKE_CASE (e.g., MY_LAPTOP)"
    exit 1
fi

MACHINE_FILE="$MACHINES_DIR/$MACHINE.nix"

# Generate hardware config if new machine
if [[ ! -f "$MACHINE_FILE" ]]; then
    echo "Creating new machine config: $MACHINE"
    nixos-generate-config --show-hardware-config > "$MACHINE_FILE"
fi

if $INSTALL_MODE; then
    # Fresh install mode
    if [[ -z "$TARGET_DISK" ]]; then
        echo "Error: --install requires a disk path (e.g., /dev/sda)"
        exit 1
    fi

    if [[ ! -b "$TARGET_DISK" ]]; then
        echo "Error: Disk not found: $TARGET_DISK"
        echo ""
        echo "Available disks:"
        lsblk -d -p -n -o NAME,SIZE,MODEL | grep -v loop || true
        exit 1
    fi

    if [[ $EUID -ne 0 ]]; then
        echo "Error: Fresh install requires root (use sudo)"
        exit 1
    fi

    echo "=== AITO Fresh Install ==="
    echo "Target disk: $TARGET_DISK (WILL BE ERASED)"
    echo "Machine: $MACHINE"
    echo ""
    read -rp "Type 'yes' to continue: " confirm
    if [[ "$confirm" != "yes" ]]; then
        echo "Aborted."
        exit 0
    fi

    # Run disko to partition (disko is in the flake)
    echo "Partitioning disk..."
    nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- \
        --mode disko \
        --flake "$SCRIPT_DIR#$MACHINE"

    # Install NixOS
    echo "Installing NixOS..."
    nixos-install --flake "$SCRIPT_DIR#$MACHINE" --no-root-passwd

    echo ""
    echo "=== Installation complete! ==="
    echo "Run 'reboot' to start your new system."
else
    # Update mode
    sudo nixos-rebuild switch --flake "$SCRIPT_DIR#$MACHINE"
fi
