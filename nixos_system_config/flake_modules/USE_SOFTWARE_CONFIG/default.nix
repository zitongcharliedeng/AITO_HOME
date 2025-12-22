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
    if [ ! -d /home/username/.git ]; then
      mkdir -p /home/username
      cd /home/username
      ${pkgs.git}/bin/git init
      chown -R username:users /home/username
    fi
  '';

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
