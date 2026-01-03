# nixos_system_config

Humans are agents too. See [AGENTS.md](AGENTS.md).

## Flash ISO to USB

```bash
# Download latest ISO from GitHub releases
gh release download --pattern "*.iso"

# Find your USB device
lsblk

# Write ISO (replace sdX with your device, e.g., sdb)
sudo dd if=nixos-installer-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Boot from USB, run `./INSTALL_SYSTEM.sh` and follow the prompts.
