def wait_for_login_screen(m):
    """Wait until the login screen is visible."""
    m.wait_until_succeeds("pgrep gnome-shell", timeout=120)
    m.sleep(30)

def wait_for_desktop(m):
    """Wait until the desktop is ready after login."""
    m.wait_until_succeeds(
        "loginctl show-user username -p State | grep -q active",
        timeout=120
    )
    m.wait_until_succeeds("pgrep -u 1000 gnome-shell", timeout=60)
    m.sleep(5)

def login(m, *, password):
    """Log in by selecting user and entering password."""
    m.send_key("ret")
    m.sleep(3)
    m.send_chars(password)
    m.send_key("ret")

# Boot and wait for login screen
wait_for_login_screen(machine)

# Login
login(machine, password="password")

# Wait for desktop
wait_for_desktop(machine)

# Screenshot - terminal should already be visible at 50% left showing git repo
machine.screenshot("terminal_visible_on_left_half_with_git_repo")
