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

def wayland_screenshot(m, name, *, uid=1000):
    m.succeed(f"su - username -c 'XDG_RUNTIME_DIR=/run/user/{uid} WAYLAND_DISPLAY=wayland-0 grim /tmp/{name}.png'")
    m.copy_from_vm(f"/tmp/{name}.png", name)

wait_for_login_screen(machine)
login(machine, username="username", password="password")
wait_for_desktop(machine)
wayland_screenshot(machine, "terminal_visible_on_left_half_with_git_repo")
