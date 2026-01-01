machine.wait_for_unit("multi-user.target")
machine.succeed("test -d /home/username/.git")
machine.succeed("cd /home/username && git status")
machine.log("Home directory is a valid git repo")
