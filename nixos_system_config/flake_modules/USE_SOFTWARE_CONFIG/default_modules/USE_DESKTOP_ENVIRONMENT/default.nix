{ pkgs, ... }:

let
  niriConfig = pkgs.writeText "config.kdl" ''
    spawn-at-startup "${pkgs.ghostty}/bin/ghostty"

    debug {
      disable-direct-scanout
      disable-cursor-plane
    }

    window-rule {
      match app-id="com.mitchellh.ghostty"
      default-column-width { proportion 0.5; }
    }
  '';
in
{
  hardware.graphics.enable = true;

  environment.variables = {
    LIBGL_ALWAYS_SOFTWARE = "1";
    GALLIUM_DRIVER = "llvmpipe";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
    MESA_GL_VERSION_OVERRIDE = "4.5";
  };

  programs.niri.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --cmd 'niri --session'";
      user = "greeter";
    };
  };

  system.activationScripts.niriConfig = ''
    mkdir -p /home/username/.config/niri
    cp -f ${niriConfig} /home/username/.config/niri/config.kdl
    chown -R username:users /home/username/.config
  '';

  environment.systemPackages = [ pkgs.git pkgs.ghostty ];

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
