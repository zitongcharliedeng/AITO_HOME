#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACHINES_DIR="$SCRIPT_DIR/flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_"
MACHINE="${1:-}"

list_machines() {
    for m in "$MACHINES_DIR"/*/; do
        basename "$m"
    done
}

if [[ -z "$MACHINE" ]]; then
    echo "Usage: BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh <MACHINE>"
    echo ""
    echo "Available:"
    list_machines
    exit 1
fi

if [[ ! -d "$MACHINES_DIR/$MACHINE" ]]; then
    echo "Machine '$MACHINE' not found"
    echo ""
    echo "Available:"
    list_machines
    exit 1
fi

nixos-generate-config --show-hardware-config > "$MACHINES_DIR/$MACHINE/hardware-configuration.nix"
sudo nixos-rebuild switch --flake "$SCRIPT_DIR#$MACHINE"
