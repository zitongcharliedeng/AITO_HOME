#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACHINES_DIR="$SCRIPT_DIR/flake_modules/USE_HARDWARE_CONFIG_FOR_MACHINE_"
MACHINE="${1:-}"

list_machines() {
    for f in "$MACHINES_DIR"/*.nix; do
        [[ -f "$f" ]] && basename "$f" .nix
    done
}

validate_machine_name() {
    [[ "$1" =~ ^[A-Z][A-Z0-9_]*$ ]]
}

if [[ -z "$MACHINE" ]]; then
    echo "Usage: BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh <MACHINE>"
    echo ""
    echo "Available machines:"
    list_machines
    echo ""
    echo "Or enter a new SCREAMING_SNAKE_CASE name to create one."
    exit 1
fi

if ! validate_machine_name "$MACHINE"; then
    echo "Machine name must be SCREAMING_SNAKE_CASE (e.g., HYPER_V, GPD_POCKET_4)"
    exit 1
fi

MACHINE_FILE="$MACHINES_DIR/$MACHINE.nix"

if [[ ! -f "$MACHINE_FILE" ]]; then
    echo "Creating new machine config: $MACHINE"
    nixos-generate-config --show-hardware-config > "$MACHINE_FILE"
    git add "$MACHINE_FILE"
fi

sudo nixos-rebuild switch --flake "$SCRIPT_DIR#$MACHINE"
