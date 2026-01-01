# Impermanence configuration
# Root is tmpfs - only /nix and /persist are real
# This module declares what needs to persist across reboots

{ lib, ... }:

{
  # Essential system state that must persist
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/systemd"
      "/var/lib/nixos"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.username = {
      directories = [
        ".ssh"
        ".local/share/direnv"
      ];
      files = [
        ".bash_history"
      ];
    };
  };

  # Allow bind mounts in user namespaces (for home-manager impermanence)
  programs.fuse.userAllowOther = true;

  # Ensure /nix/persist exists before impermanence tries to use it
  # Only runs if /nix is writable (not in test VMs where /nix is read-only)
  system.activationScripts.persistDirs = lib.mkBefore ''
    if [ -w /nix ]; then
      mkdir -p /nix/persist
    fi
  '';
}
