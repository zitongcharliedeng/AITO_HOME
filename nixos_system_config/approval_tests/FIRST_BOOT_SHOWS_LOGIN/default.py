def wait_for_login_screen(m):
    """Wait until the login screen is visible. Implementation detail: GDM runs gnome-shell."""
    m.wait_until_succeeds("pgrep gnome-shell", timeout=120)
    m.sleep(30)  # Give GDM time to fully render

wait_for_login_screen(machine)
machine.screenshot("user_sees_login_prompt")
