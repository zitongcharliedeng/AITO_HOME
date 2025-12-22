{ pkgs, ... }:

let
  niriConfig = pkgs.writeText "config.kdl" ''
    spawn-at-startup "${pkgs.foot}/bin/foot"

    window-rule {
      match app-id="foot"
      default-column-width { proportion 0.5; }
    }
  '';
in
{
  programs.niri.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --cmd niri";
      user = "greeter";
    };
  };

  system.activationScripts.niriConfig = ''
    mkdir -p /home/username/.config/niri
    cp -f ${niriConfig} /home/username/.config/niri/config.kdl
    chown -R username:users /home/username/.config
  '';

  environment.systemPackages = [ pkgs.git pkgs.foot ];

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
