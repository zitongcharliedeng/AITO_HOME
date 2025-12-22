def wait_for_system():
    machine.wait_for_unit("multi-user.target")

wait_for_system()
machine.screenshot("user_sees_login_prompt")
