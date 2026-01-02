{ pkgs, ... }:

let
  aitoCommand = pkgs.writeShellScriptBin "aito" ''
    case "$1" in
      chat)
        if [ "$2" = "--test-mode" ]; then
          read -r input
          echo "Hello! I'm AITO, your digital assistant. You said: $input"
        else
          echo "AITO Digital Assistant"
          echo "API mode not yet configured. Use --test-mode for testing."
          exit 1
        fi
        ;;
      --version)
        echo "aito version 0.1.0"
        ;;
      *)
        echo "Usage: aito <command>"
        echo "Commands:"
        echo "  chat [--test-mode]  Start a conversation"
        echo "  --version           Show version"
        ;;
    esac
  '';
in
{
  environment.systemPackages = [ aitoCommand ];
}
