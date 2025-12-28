{ pkgs, lib, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.gnome.core-utilities.enable = false;

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-initial-setup
  ];

  programs.dconf = {
    enable = true;
    profiles.user.databases = [{
      settings = {
        "org/gnome/shell" = {
          welcome-dialog-last-shown-version = "999.0.0";
        };
        "org/gnome/desktop/privacy" = {
          remember-recent-files = false;
        };
        "org/gnome/desktop/session" = {
          idle-delay = lib.gvariant.mkUint32 0;
        };
        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing";
        };
      };
    }];
  };

  hardware.graphics.enable = true;

  environment.systemPackages = with pkgs; [
    git
    gnome-terminal
    firefox
  ];

  programs.bash.interactiveShellInit = ''
    __update_ps1() {
      local branch=$(${pkgs.git}/bin/git branch 2>/dev/null | grep '^*' | sed 's/* //')
      if [ -n "$branch" ]; then
        PS1="[\u@\h:\w ($branch)]\\$ "
      else
        PS1="[\u@\h:\w]\\$ "
      fi
    }
    PROMPT_COMMAND=__update_ps1
  '';
}
