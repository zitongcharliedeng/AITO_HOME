{ pkgs, ... }:

{
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
  };

  # Hardware support
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  programs.light.enable = true;  # brightness control

  # i3 with auto-login
  services.xserver = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      configFile = ./i3/config;
    };
    displayManager.lightdm.enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = "username";
    };
  };

  # Audio for volume keys
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Ghostty terminal
  environment.systemPackages = with pkgs; [
    git
    ghostty
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
