def wait_for_login_screen(m):
    """Wait until the login screen is visible. Implementation detail: GDM greeter."""
    m.wait_until_succeeds("pgrep -f gsd-", timeout=120)
    m.sleep(5)

wait_for_login_screen(machine)
machine.screenshot("user_sees_login_prompt")
