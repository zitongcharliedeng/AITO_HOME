{ lib, ... }:

{
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

  programs.fuse.userAllowOther = true;

  system.activationScripts.createPersistDirectory = lib.mkBefore ''
    if [ -w /nix ]; then
      mkdir -p /nix/persist
    fi
  '';
}
