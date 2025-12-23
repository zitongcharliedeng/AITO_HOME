{ modulesPath, pkgs, ... }:

let
  vmNiriConfig = pkgs.writeText "config.kdl" ''
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
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

  boot.loader.grub.device = "/dev/vda";

  environment.systemPackages = [ pkgs.grim ];

  environment.variables = {
    RUST_LOG = "debug,niri=debug,smithay=debug";
    LIBGL_ALWAYS_SOFTWARE = "1";
  };

  system.activationScripts.niriConfig = pkgs.lib.mkForce ''
    mkdir -p /home/username/.config/niri
    cp -f ${vmNiriConfig} /home/username/.config/niri/config.kdl
    chown -R username:users /home/username/.config
  '';
}
