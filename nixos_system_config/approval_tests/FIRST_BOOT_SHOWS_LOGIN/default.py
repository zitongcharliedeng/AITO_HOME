machine.wait_for_unit("display-manager.service")
machine.wait_for_window("gdm")
machine.screenshot("user_sees_login_prompt")
