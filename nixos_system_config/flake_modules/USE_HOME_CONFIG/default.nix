# Home Manager configuration for user
# Declarative home directory management

{ pkgs, ... }:

{
  home.stateVersion = "24.11";

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "User";
      user.email = "user@aito";
      init.defaultBranch = "main";
      safe.directory = "/home/username";
    };
  };

  # Bash configuration
  programs.bash = {
    enable = true;
    historyControl = [ "ignoredups" "erasedups" ];
  };

  # Home directory as git repo (initialized declaratively)
  home.activation.initHomeGit = {
    after = [ "writeBoundary" ];
    before = [];
    data = ''
      if [ ! -d "$HOME/.git" ]; then
        ${pkgs.git}/bin/git init "$HOME"
        ${pkgs.git}/bin/git -C "$HOME" add -A
        ${pkgs.git}/bin/git -C "$HOME" commit -m "Initial home state" --allow-empty || true
      fi
    '';
  };
}
