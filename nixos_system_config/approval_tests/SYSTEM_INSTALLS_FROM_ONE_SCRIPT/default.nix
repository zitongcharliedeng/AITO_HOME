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
# Pattern from nixpkgs/nixos/tests/installer.nix:
# - installer node boots from /dev/vdb, installs to /dev/vda
# - target node boots from /dev/vda (shares state_dir with installer)

pkgs.testers.runNixOSTest {
  name = "SYSTEM_INSTALLS_FROM_ONE_SCRIPT";

  nodes = {
    # The installer: simulates NixOS ISO environment
    installer = { config, pkgs, lib, ... }: {
      virtualisation = {
        memorySize = 4096;
        diskSize = 8192;
        cores = 4;
        # Boot from small disk, install to main disk
        emptyDiskImages = [ 512 ];
        rootDevice = "/dev/vdb";
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

      # Include all dependencies needed for the install
      # (test VM can't access network)
      system.extraDependencies = with pkgs; [
        stdenv
        bintools
      ];

      # Make the repo available (simulates git clone)
      virtualisation.sharedDirectories.repo = {
        source = "${../..}";
        target = "/repo";
      };
    };

    # The target: boots from installed system
    target = { config, pkgs, lib, ... }: {
      virtualisation = {
        memorySize = 4096;
        cores = 4;
        useBootLoader = true;
        useDefaultFilesystems = false;
      };

      # Fake filesystem (never used - we boot from installed disk)
      virtualisation.fileSystems."/" = {
        device = "/dev/disk/by-label/not-used";
        fsType = "ext4";
      };
    };
  };

  testScript = builtins.readFile ./default.py;
}
