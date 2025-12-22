{ pkgs, ... }:

{
  programs.sway = {
    enable = true;
    extraPackages = [ pkgs.ghostty ];
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --cmd sway";
      user = "greeter";
    };
  };

  environment.etc."sway/config".text = ''
    bar {
      mode invisible
    }
    exec ghostty
    for_window [app_id="ghostty"] resize set width 50 ppt
  '';

  environment.systemPackages = [ pkgs.git ];
}
