machine.wait_for_unit("multi-user.target")

with subtest("system boots and user can login"):
    machine.succeed("loginctl list-users | grep username")
