{ pkgs, systemModules, impermanence }:

# End-to-end test: The FULL user flow
#
# 1. Boot NixOS ISO-like environment
# 2. Run the ONE install script
# 3. Reboot into installed system
# 4. Verify everything works:
#    - System boots
#    - Home directory is git repo
#    - Impermanence persists data across reboot
#
# Pattern from nix-community/disko tests:
# - Single installer node with extra disk
# - Use create_machine() in testScript to boot from installed disk

pkgs.testers.runNixOSTest {
  name = "SYSTEM_INSTALLS_FROM_ONE_SCRIPT";

  nodes.installer = { config, pkgs, lib, ... }: {
    virtualisation = {
      memorySize = 4096;
      diskSize = 8192;
      cores = 4;
      # Extra disk at /dev/vdb for installation target
      emptyDiskImages = [ 8192 ];
    };

    # Packages available on NixOS ISO
    environment.systemPackages = with pkgs; [
      git
      parted
      dosfstools
      e2fsprogs
      util-linux
    ];

    # Enable flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Make the repo available (simulates git clone)
    # ../../../ goes from approval_tests/SYSTEM_INSTALLS_FROM_ONE_SCRIPT/ to AITO_HOME root
    virtualisation.sharedDirectories.repo = {
      source = "${../../..}";
      target = "/repo";
    };
  };

  testScript = ''
    def create_test_machine(oldmachine=None, **kwargs):
        """Boot a new VM from the disk we installed to (pattern from disko tests)"""
        start_command = [
            "${pkgs.qemu_test}/bin/qemu-kvm",
            "-cpu", "max",
            "-m", "2048",
            "-virtfs", "local,path=/nix/store,security_model=none,mount_tag=nix-store",
            "-drive", f"file={oldmachine.state_dir}/empty0.qcow2,id=drive1,if=none,index=1,werror=report",
            "-device", "virtio-blk-pci,drive=drive1,bootindex=1",
        ]
        machine = create_machine(start_command=" ".join(start_command), **kwargs)
        driver.machines.append(machine)
        return machine

    # === PHASE 1: Install ===
    installer.start()
    installer.wait_for_unit("multi-user.target")

    # Copy repo to writable location (shared dir is read-only)
    installer.succeed("cp -r /repo /tmp/AITO_HOME")
    installer.succeed("chmod -R +w /tmp/AITO_HOME")

    # Run install script targeting /dev/vdb (extra disk)
    installer.succeed(
        "cd /tmp/AITO_HOME/nixos_system_config && "
        "echo 'yes' | ./BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh --install /dev/vdb TEST_VM"
    )

    # Verify install completed
    installer.succeed("test -d /mnt/nix/store")
    installer.log("Install completed - shutting down installer")

    installer.succeed("umount -R /mnt")
    installer.succeed("sync")
    installer.shutdown()

    # === PHASE 2: Boot installed system ===
    target = create_test_machine(oldmachine=installer, name="installed")
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
  '';
}
