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
    bar {
      mode invisible
    }
    exec ${pkgs.ghostty}/bin/ghostty
    for_window [app_id="com.mitchellh.ghostty"] resize set width 50 ppt
  '';

  environment.systemPackages = [ pkgs.git ];
}
