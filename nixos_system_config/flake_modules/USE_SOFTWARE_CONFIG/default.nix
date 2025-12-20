{ ... }:

{
  imports = [
    # Add software modules here as we build them
    # ./default_modules/USE_PINNED_LLM_TERMINAL
  ];

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.username = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    initialPassword = "password";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}
