# Test: Home directory is git repo and persists across reboot
#
# This tests:
# 1. Home-manager creates git repo in home directory
# 2. Impermanence persists home directory across reboot

machine.wait_for_unit("multi-user.target")

# Verify home directory is a git repo
machine.succeed("test -d /home/username/.git")
machine.succeed("su - username -c 'git status'")
machine.log("Home directory is a valid git repo")

# Create a file to test persistence
machine.succeed("su - username -c 'echo test > ~/persistence-test'")

# Reboot
machine.shutdown()
machine.start()
machine.wait_for_unit("multi-user.target")

# Verify git repo still exists after reboot
machine.succeed("test -d /home/username/.git")
machine.succeed("su - username -c 'git status'")

# Verify test file persisted
machine.succeed("test -f /home/username/persistence-test")
machine.succeed("su - username -c 'cat ~/persistence-test | grep test'")

machine.log("Home directory persisted across reboot")
