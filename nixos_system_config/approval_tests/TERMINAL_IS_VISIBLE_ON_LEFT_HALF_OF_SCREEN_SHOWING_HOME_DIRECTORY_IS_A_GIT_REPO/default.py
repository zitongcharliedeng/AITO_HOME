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
    m.succeed("echo '=== DRM devices ===' && ls -la /dev/dri/ || echo 'No DRI devices'")
    m.succeed("echo '=== Niri process ===' && pgrep -a niri || echo 'Niri not running'")
    m.succeed("echo '=== User runtime dir ===' && ls -la /run/user/1000/ || echo 'No runtime dir'")
    m.succeed("echo '=== Wayland sockets ===' && ls -la /run/user/1000/wayland* 2>/dev/null || echo 'No wayland sockets'")
    m.succeed("echo '=== Journal niri ===' && journalctl -u greetd --no-pager -n 50 || echo 'No greetd logs'")

def wayland_screenshot(m, name, *, uid=1000):
    debug_display_state(m)
    result = m.execute(f"test -S /run/user/{uid}/wayland-0")
    if result[0] == 0:
        m.succeed(f"su - username -c 'XDG_RUNTIME_DIR=/run/user/{uid} WAYLAND_DISPLAY=wayland-0 grim /tmp/{name}.png'")
        m.copy_from_vm(f"/tmp/{name}.png", name)
    else:
        m.log("Wayland socket not found, falling back to screendump")
        m.screenshot(name)

wait_for_login_screen(machine)
login(machine, username="username", password="password")
wait_for_desktop(machine)
wayland_screenshot(machine, "terminal_visible_on_left_half_with_git_repo")
