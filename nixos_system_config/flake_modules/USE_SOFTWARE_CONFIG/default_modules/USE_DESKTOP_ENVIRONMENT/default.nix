{ pkgs, ... }:

{
  programs.sway = {
    enable = true;
    extraPackages = [ pkgs.ghostty ];
    extraSessionCommands = ''
      export XDG_CURRENT_DESKTOP=sway
    '';
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --cmd sway";
      user = "greeter";
    };
  };

  environment.etc."sway/config.d/aito.conf".text = ''
    exec swaymsg bar mode invisible
    exec ${pkgs.ghostty}/bin/ghostty
    for_window [app_id="com.mitchellh.ghostty"] floating enable, resize set width 50 ppt height 100 ppt, move position 0 0
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
