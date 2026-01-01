# Test: BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh works from NixOS ISO-like environment
#
# What we test:
# 1. Script runs without error
# 2. Disko partitions the target disk (with tmpfs root)
# 3. NixOS installs to /mnt
#
# What we can't test (requires actual reboot):
# - System boots after install
# - Impermanence works correctly
# - Home directory is git repo (home-manager)
# - SSH works

machine.wait_for_unit("multi-user.target")

# Copy repo to writable location (shared dir is read-only)
machine.succeed("cp -r /repo /tmp/AITO_HOME")
machine.succeed("chmod -R +w /tmp/AITO_HOME")

# Verify the install script exists
machine.succeed("test -x /tmp/AITO_HOME/nixos_system_config/BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh")

# The second disk is /dev/vdb in QEMU
# Run install script in install mode (non-interactive via yes pipe)
machine.succeed(
    "cd /tmp/AITO_HOME/nixos_system_config && "
    "echo 'yes' | ./BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh --install /dev/vdb TEST_VM"
)

# Verify disk was partitioned (has partitions)
machine.succeed("lsblk /dev/vdb | grep -E 'part'")

# Verify filesystems were created (EFI vfat and nix ext4)
machine.succeed("lsblk -f /dev/vdb | grep -E 'vfat|ext4'")

# Verify NixOS was installed (has /mnt with nix store)
machine.succeed("test -d /mnt/nix/store")

# Verify boot partition was mounted
machine.succeed("mountpoint /mnt/boot")

# Verify /nix is mounted (for impermanence)
machine.succeed("mountpoint /mnt/nix")

machine.log("Install script completed successfully!")
