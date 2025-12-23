def wait_for_login_screen(m):
    m.sleep(120)

def wait_for_desktop(m):
    m.sleep(60)

def login(m, *, username, password):
    m.send_chars(username)
    m.send_key("ret")
    m.sleep(2)
    m.send_chars(password)
    m.send_key("ret")

def debug_display_state(m):
    # Capture and log output for debugging
    output = m.succeed("ls -la /dev/dri/ 2>&1 || echo 'No DRI devices'")
    m.log(f"=== DRM devices ===\n{output}")

    output = m.succeed("pgrep -a niri 2>&1 || echo 'Niri not running'")
    m.log(f"=== Niri process ===\n{output}")

    output = m.succeed("ls -la /run/user/1000/ 2>&1 || echo 'No runtime dir'")
    m.log(f"=== User runtime dir ===\n{output}")

    output = m.succeed("ls -la /run/user/1000/wayland* 2>&1 || echo 'No wayland sockets'")
    m.log(f"=== Wayland sockets ===\n{output}")

    # Get niri's actual error logs from journalctl
    output = m.succeed("journalctl -u greetd --no-pager -n 100 2>&1 || echo 'No greetd logs'")
    m.log(f"=== Journal greetd ===\n{output}")

    # Also check user's niri logs
    output = m.succeed("journalctl --user -u niri --no-pager -n 100 2>&1 || echo 'No niri user logs'")
    m.log(f"=== Journal niri user ===\n{output}")

    # Check for EGL/Mesa errors
    output = m.succeed("dmesg | grep -iE 'drm|egl|mesa|niri|gpu' | tail -50 2>&1 || echo 'No relevant dmesg'")
    m.log(f"=== dmesg DRM/EGL ===\n{output}")

def find_wayland_socket(m, uid=1000):
    """Find Wayland socket dynamically.

    Niri creates: wayland-1 (standard) and niri.wayland-1.PID.sock (internal)
    Standard compositors use: wayland-0
    """
    # Check for standard wayland sockets (wayland-0, wayland-1, etc.)
    for i in range(10):
        result = m.execute(f"test -S /run/user/{uid}/wayland-{i}")
        if result[0] == 0:
            m.log(f"Found standard Wayland socket: wayland-{i}")
            return f"wayland-{i}"

    return None

def wayland_screenshot(m, name, *, uid=1000):
    debug_display_state(m)
    socket = find_wayland_socket(m, uid)
    if socket:
        m.log(f"Attempting grim screenshot via Wayland socket: {socket}")
        grim_cmd = f"su - username -c 'XDG_RUNTIME_DIR=/run/user/{uid} WAYLAND_DISPLAY={socket} grim /tmp/{name}.png'"
        result = m.execute(grim_cmd)
        if result[0] == 0:
            m.log("grim screenshot successful")
            m.copy_from_vm(f"/tmp/{name}.png", name)
            return
        else:
            m.log(f"grim failed (exit {result[0]}): {result[1]}")
            m.log("Falling back to QEMU screendump")
    else:
        m.log("No Wayland socket found")
    # Fallback to QEMU screendump
    m.screenshot(name)

wait_for_login_screen(machine)
login(machine, username="username", password="password")
wait_for_desktop(machine)
wayland_screenshot(machine, "niri_starts_after_login")
