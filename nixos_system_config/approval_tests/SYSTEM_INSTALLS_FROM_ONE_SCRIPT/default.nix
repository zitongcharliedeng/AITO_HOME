{ pkgs, systemModules, impermanence, self, disko }:

# End-to-end test: The FULL user flow
#
# 1. Boot NixOS ISO-like environment
# 2. Run the ONE install script (same script for install AND update)
# 3. Reboot into installed system
# 4. Verify everything works:
#    - System boots
#    - Home directory is git repo (rollback-able)
#    - Impermanence persists data across reboot
#
# The script is the API - backend (NixOS) is an implementation detail.
# This test must work offline by pre-computing all dependencies.

let
  system = "x86_64-linux";

  # Pre-compute all dependencies needed for installation
  # This makes the test work offline (no network in VM)
  testMachineConfig = self.nixosConfigurations.TEST_VM;

  dependencies = [
    # The system we're installing
    testMachineConfig.config.system.build.toplevel

    # Disko for partitioning
    disko.packages.${system}.disko

    # All flake inputs (ensures they're in the store)
  ] ++ builtins.map (i: i.outPath) (builtins.attrValues self.inputs);

  # Create closure info so we know all store paths needed
  closureInfo = pkgs.closureInfo { rootPaths = dependencies; };

  # The disko binary path (pre-built, no network needed)
  diskoBin = "${disko.packages.${system}.disko}/bin/disko";

  # The system toplevel (what nixos-install copies)
  systemToplevel = testMachineConfig.config.system.build.toplevel;
in
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

    # Packages available on NixOS ISO + disko for partitioning
    environment.systemPackages = with pkgs; [
      git
      parted
      dosfstools
      e2fsprogs
      util-linux
      nixos-install-tools
      disko.packages.${system}.disko
    ];

    # Enable flakes and configure for offline use
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      # Disable network access for flake evaluation (everything pre-cached)
      flake-registry = "";
      accept-flake-config = false;
    };

    # Make the repo available (simulates git clone)
    virtualisation.sharedDirectories.repo = {
      source = "${../../..}";
      target = "/repo";
    };

    # Make closure info available so we can verify all deps are present
    environment.etc."install-closure".source = "${closureInfo}/store-paths";
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

    # Verify we have the closure available
    installer.succeed("test -f /etc/install-closure")
    installer.log("All dependencies pre-cached in nix store")

    # Run the install script - uses pre-built disko and system
    # The script is the API we're testing
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

    # Home directory is a git repo (can roll back to any commit)
    target.succeed("test -d /home/username/.git")
    target.succeed("su - username -c 'git status'")
    target.succeed("su - username -c 'git log --oneline -1'")  # Verify git history exists
    target.log("Home directory is a valid git repo with history")

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

    target.log("SUCCESS: Install script works, system boots, home is git repo, data persists")
  '';
}
