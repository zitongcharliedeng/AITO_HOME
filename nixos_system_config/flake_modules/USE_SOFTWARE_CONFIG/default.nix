{ pkgs, ... }:

{
  imports = [
    ./default_modules/USE_DESKTOP_ENVIRONMENT
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "AITO";
  networking.networkmanager.enable = true;

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  users.mutableUsers = false;
  users.users.username = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    initialPassword = "password";
    home = "/home/username";
  };

  system.activationScripts.initHomeGit = ''
    set -x
    if [ ! -d /home/username/.git ]; then
      mkdir -p /home/username
      ${pkgs.git}/bin/git init /home/username
      ${pkgs.git}/bin/git -C /home/username config user.email "user@aito"
      ${pkgs.git}/bin/git -C /home/username config user.name "User"
      ${pkgs.git}/bin/git config --global --add safe.directory /home/username
      HOME=/root ${pkgs.git}/bin/git -C /home/username commit --allow-empty -m "init" || echo "commit failed with $?"
      chown -R username:users /home/username
    fi
    set +x
  '';

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  system.stateVersion = "24.11";
}
