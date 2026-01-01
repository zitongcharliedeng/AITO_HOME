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

let
  # Module to auto-format the installer's root device
  autoFormatRootDevice = { lib, config, pkgs, ... }:
    let rootDevice = config.virtualisation.rootDevice;
    in {
      boot.initrd.extraUtilsCommands = lib.mkIf (!config.boot.initrd.systemd.enable) ''
        copy_bin_and_libs ${pkgs.e2fsprogs}/bin/mke2fs
      '';
      boot.initrd.postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable) ''
        FSTYPE=$(blkid -o value -s TYPE ${rootDevice} || true)
        PARTTYPE=$(blkid -o value -s PTTYPE ${rootDevice} || true)
        if test -z "$FSTYPE" -a -z "$PARTTYPE"; then
            mke2fs -t ext4 ${rootDevice}
        fi
      '';
    };
in
pkgs.testers.runNixOSTest {
  name = "SYSTEM_INSTALLS_FROM_ONE_SCRIPT";

  nodes = {
    # The installer: simulates NixOS ISO environment
    installer = { config, pkgs, lib, ... }: {
      imports = [ autoFormatRootDevice ];

      virtualisation = {
        memorySize = 4096;
        diskSize = 8192;
        cores = 4;
        # Boot from small disk (/dev/vdb), install to main disk (/dev/vda)
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

      # Make the repo available (simulates git clone)
      # ../../../ goes from approval_tests/SYSTEM_INSTALLS_FROM_ONE_SCRIPT/ to AITO_HOME root
      virtualisation.sharedDirectories.repo = {
        source = "${../../..}";
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
