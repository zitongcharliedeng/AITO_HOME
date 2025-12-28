machine.wait_for_unit("display-manager.service")
machine.wait_for_unit("graphical-session.target", "username", timeout=120)
machine.sleep(10)
machine.screenshot("gnome_desktop_loads")
