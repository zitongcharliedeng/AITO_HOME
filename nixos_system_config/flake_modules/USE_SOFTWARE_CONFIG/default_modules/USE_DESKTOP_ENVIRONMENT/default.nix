{ pkgs, ... }:

{
  programs.sway = {
    enable = true;
    extraPackages = [ pkgs.ghostty ];
    extraSessionCommands = ''
      export XDG_CURRENT_DESKTOP=sway
    '';
    extraConfig = ''
      bar swaybar_command true
      exec ${pkgs.ghostty}/bin/ghostty
      for_window [app_id="com.mitchellh.ghostty"] floating enable, resize set width 50 ppt height 100 ppt, move position 0 0
    '';
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --cmd sway";
      user = "greeter";
    };
  };

  environment.systemPackages = [ pkgs.git ];

  programs.bash.interactiveShellInit = ''
    __git_ps1() {
      local branch=$(${pkgs.git}/bin/git branch 2>/dev/null | grep '^*' | sed 's/* //')
      [ -n "$branch" ] && echo " ($branch)"
    }
    PS1='[\u@\h:\w$(__git_ps1)]\$ '
  '';
}
