machine.wait_for_unit("display-manager.service")
machine.sleep(5)
machine.screenshot("user_sees_login_prompt")
