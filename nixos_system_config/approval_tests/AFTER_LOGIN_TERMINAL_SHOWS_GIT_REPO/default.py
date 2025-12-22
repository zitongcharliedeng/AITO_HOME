def wait_for_login_screen(m):
    """Wait until the login screen is visible."""
    m.wait_until_succeeds("pgrep gnome-shell", timeout=120)
    m.sleep(30)

def wait_for_desktop(m):
    """Wait until the GNOME desktop is ready after login."""
    # Wait for gnome-shell running as UID 1000 (the user, not gdm)
    # GDM's gnome-shell runs as gdm user, user session runs as UID 1000
    m.wait_until_succeeds(
        "pgrep -u 1000 gnome-shell",
        timeout=120
    )
    m.sleep(15)  # Give desktop time to fully render

def login(m, password):
    """Log in - click user first, then enter password."""
    # Click on the username (press Enter to select the shown user)
    m.send_key("ret")
    m.sleep(3)
    # Now type the password
    m.send_chars(password)
    m.send_key("ret")

def open_terminal(m):
    """Open terminal via Super key search."""
    m.send_key("super_l")
    m.sleep(2)
    m.send_chars("terminal")
    m.sleep(2)
    m.send_key("ret")
    m.sleep(3)

def run_command_in_terminal(m, cmd):
    """Type a command in the terminal."""
    m.send_chars(cmd)
    m.send_key("ret")
    m.sleep(2)

# Boot and wait for login
wait_for_login_screen(machine)

# Login
login(machine, "password")

# Wait for desktop to fully load
wait_for_desktop(machine)

# Debug: take screenshot after desktop loads
machine.screenshot("debug_after_login")

# Open terminal
open_terminal(machine)

# Run ls -la to show git repo
run_command_in_terminal(machine, "ls -la")
machine.sleep(2)

machine.screenshot("terminal_shows_git_repo")
