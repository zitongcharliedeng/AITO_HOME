# End-to-end test: Full user flow
#
# 1. Boot ISO-like environment (installer)
# 2. Run ONE install script
# 3. Reboot into installed system (target)
# 4. Verify: system boots, home is git repo, data persists

# === PHASE 1: Install ===
installer.start()
installer.wait_for_unit("multi-user.target")

# Copy repo to writable location (shared dir is read-only)
installer.succeed("cp -r /repo /tmp/AITO_HOME")
installer.succeed("chmod -R +w /tmp/AITO_HOME")

# Run install script targeting /dev/vda (main disk)
installer.succeed(
    "cd /tmp/AITO_HOME/nixos_system_config && "
    "echo 'yes' | ./BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh --install /dev/vda TEST_VM"
)

# Verify install completed
installer.succeed("test -d /mnt/nix/store")
installer.log("Install completed - shutting down installer")

installer.succeed("umount -R /mnt")
installer.succeed("sync")
installer.shutdown()

# === PHASE 2: Boot installed system ===
# Share state directory so target boots from the disk we just installed to
target.state_dir = installer.state_dir

target.start()
target.wait_for_unit("multi-user.target")
target.log("Installed system booted successfully!")

# === PHASE 3: Verify system works ===

# Home directory is a git repo
target.succeed("test -d /home/username/.git")
target.succeed("su - username -c 'git status'")
target.log("Home directory is a valid git repo")

# Create test file to verify persistence
target.succeed("su - username -c 'echo persistence-test > ~/test-file'")

# === PHASE 4: Reboot and verify persistence ===
target.shutdown()
target.start()
target.wait_for_unit("multi-user.target")

# Home directory still git repo after reboot
target.succeed("test -d /home/username/.git")
target.succeed("su - username -c 'git status'")

# Test file persisted (impermanence working)
target.succeed("test -f /home/username/test-file")
target.succeed("su - username -c 'cat ~/test-file | grep persistence-test'")

target.log("SUCCESS: System installed, boots, home is git repo, data persists across reboot")
