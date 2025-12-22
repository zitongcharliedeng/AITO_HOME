def wait_for_login_screen(m):
    """Wait until the login screen is visible."""
    m.wait_until_succeeds("pgrep gnome-shell", timeout=120)
    m.sleep(30)

def login(m, password):
    """Log in - click user first, then enter password."""
    # Click on the username (press Enter to select the shown user)
    m.send_key("ret")
    m.sleep(3)
    # Now type the password
    m.send_chars(password)
    m.send_key("ret")
    m.sleep(15)

def open_terminal(m):
    """Open GNOME Console (kgx) - GNOME's default terminal."""
    m.send_key("super")
    m.sleep(3)
    m.send_chars("console")
    m.sleep(2)
    m.send_key("ret")
    m.sleep(5)

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
machine.sleep(10)

# Open terminal
open_terminal(machine)

# Run ls -la to show git repo
run_command_in_terminal(machine, "ls -la")
machine.sleep(2)

machine.screenshot("terminal_shows_git_repo")
