{ pkgs, ... }:

{
  programs.niri.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --cmd niri-session";
      user = "greeter";
    };
  };

  environment.etc."niri/config.kdl".text = ''
    spawn-at-startup "${pkgs.ghostty}/bin/ghostty"

    window-rule {
      match app-id="com.mitchellh.ghostty"
      default-column-width { proportion 0.5; }
    }
  '';

  environment.systemPackages = [ pkgs.git ];

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
