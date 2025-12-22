def wait_for_login_screen(m):
    m.sleep(120)

wait_for_login_screen(machine)
machine.screenshot("user_sees_login_prompt")
