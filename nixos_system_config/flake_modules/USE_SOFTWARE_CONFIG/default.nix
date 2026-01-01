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
      chown -R username:users /home/username
      ${pkgs.sudo}/bin/sudo -u username ${pkgs.git}/bin/git init /home/username
      ${pkgs.sudo}/bin/sudo -u username ${pkgs.git}/bin/git -C /home/username config user.email "user@aito"
      ${pkgs.sudo}/bin/sudo -u username ${pkgs.git}/bin/git -C /home/username config user.name "User"
      ${pkgs.sudo}/bin/sudo -u username ${pkgs.git}/bin/git -C /home/username commit --allow-empty -m "init"
    fi
  '';

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  system.stateVersion = "24.11";
}
