machine.wait_for_unit("multi-user.target")

with subtest("01 - login prompt appears"):
    machine.wait_until_succeeds("pgrep -f agetty")
    machine.screenshot("01_login_prompt")
