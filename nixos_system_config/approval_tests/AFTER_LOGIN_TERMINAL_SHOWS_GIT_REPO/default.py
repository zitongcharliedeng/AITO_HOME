def wait_for_login_screen(m):
    """Wait until the login screen is visible."""
    m.wait_until_succeeds("pgrep gnome-shell", timeout=120)
    m.sleep(30)

def login(m, username, password):
    """Log in as a user."""
    m.send_chars(f"{password}\n")
    m.sleep(10)

def open_terminal(m):
    """Open a terminal."""
    m.send_key("super")
    m.sleep(2)
    m.send_chars("terminal\n")
    m.sleep(5)

def run_command_in_terminal(m, cmd):
    """Type a command in the terminal."""
    m.send_chars(f"{cmd}\n")
    m.sleep(2)

# Boot and wait for login
wait_for_login_screen(machine)

# Login (username is already selected, just need password)
login(machine, "username", "password")

# Wait for desktop
machine.sleep(15)

# Open terminal
open_terminal(machine)

# Run ls -la to show git repo
run_command_in_terminal(machine, "ls -la")
machine.sleep(2)

machine.screenshot("terminal_shows_git_repo")
