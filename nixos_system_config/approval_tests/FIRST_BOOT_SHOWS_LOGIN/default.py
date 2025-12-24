def wait_for_login_screen(m):
    m.wait_for_text("login")

wait_for_login_screen(machine)
machine.screenshot("user_sees_login_prompt")
