def wait_for_login_screen(m):
    """Wait until the login screen is visible."""
    m.wait_until_succeeds("pgrep gnome-shell", timeout=120)
    m.sleep(30)

def wait_for_desktop(m):
    """Wait until the GNOME desktop is ready after login."""
    # Wait for user session to be graphical and active via loginctl
    m.wait_until_succeeds(
        "loginctl show-user username -p State | grep -q active",
        timeout=120
    )
    # Wait for gnome-shell running as the user (not GDM's greeter)
    m.wait_until_succeeds(
        "pgrep -u 1000 gnome-shell",
        timeout=60
    )
    # Wait for GNOME Shell to be fully initialized by checking for the overview/desktop
    # The overview (Activities) is the key indicator that the session is ready
    m.wait_until_succeeds(
        "dbus-send --session --dest=org.gnome.Shell --type=method_call --print-reply "
        "/org/gnome/Shell org.freedesktop.DBus.Properties.Get "
        "string:'org.gnome.Shell' string:'OverviewActive' 2>/dev/null || "
        "sudo -u username DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus "
        "dbus-send --session --dest=org.gnome.Shell --type=method_call --print-reply "
        "/org/gnome/Shell org.freedesktop.DBus.Properties.Get "
        "string:'org.gnome.Shell' string:'OverviewActive'",
        timeout=60
    )
    m.sleep(5)  # Brief pause for rendering

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
