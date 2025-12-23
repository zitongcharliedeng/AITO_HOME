{ modulesPath, pkgs, ... }:

let
  vmNiriConfig = pkgs.writeText "config.kdl" ''
    spawn-at-startup "${pkgs.ghostty}/bin/ghostty"

    debug {
      disable-direct-scanout
      disable-cursor-plane
      render-drm-device "/dev/dri/renderD128"
    }

    window-rule {
      match app-id="com.mitchellh.ghostty"
      default-column-width { proportion 0.5; }
    }
  '';
in
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  # Enable hardware graphics for Mesa/EGL support (required by niri)
  hardware.graphics.enable = true;

  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

  boot.loader.grub.device = "/dev/vda";

  boot.kernelModules = [ "vkms" ];

  environment.systemPackages = [ pkgs.grim ];

  # Mesa software rendering environment - must match production config
  environment.variables = {
    LIBGL_ALWAYS_SOFTWARE = "1";
    GALLIUM_DRIVER = "llvmpipe";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
    MESA_GL_VERSION_OVERRIDE = "4.5";
    # Debug logging
    RUST_LOG = "debug,niri=debug,smithay=debug";
  };

  # Ensure greetd also has these variables
  systemd.services.greetd.environment = {
    LIBGL_ALWAYS_SOFTWARE = "1";
    GALLIUM_DRIVER = "llvmpipe";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
    MESA_GL_VERSION_OVERRIDE = "4.5";
  };

  system.activationScripts.niriConfig = pkgs.lib.mkForce ''
    mkdir -p /home/username/.config/niri
    cp -f ${vmNiriConfig} /home/username/.config/niri/config.kdl
    chown -R username:users /home/username/.config
  '';
}
