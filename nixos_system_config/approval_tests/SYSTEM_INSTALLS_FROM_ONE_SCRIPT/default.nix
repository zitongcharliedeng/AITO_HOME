{ pkgs, systemModules, impermanence }:

# This test verifies the install script can:
# 1. Run on a NixOS ISO-like environment
# 2. Partition a disk with disko
# 3. Install NixOS to the disk
#
# Note: We can't easily test the reboot in NixOS VM tests,
# so we verify up to the nixos-install step.

pkgs.testers.runNixOSTest {
  name = "SYSTEM_INSTALLS_FROM_ONE_SCRIPT";

  nodes.machine = { config, pkgs, lib, ... }: {
    # Simulate NixOS installer environment
    virtualisation = {
      memorySize = 4096;
      diskSize = 8192;
      # Extra disk for installation target
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
    virtualisation.sharedDirectories.repo = {
      source = "${../..}";
      target = "/repo";
    };
  };

  testScript = builtins.readFile ./default.py;
}
