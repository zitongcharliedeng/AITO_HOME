machine.wait_for_unit("display-manager.service")
machine.wait_for_text("username")
machine.screenshot("user_sees_login_prompt")
