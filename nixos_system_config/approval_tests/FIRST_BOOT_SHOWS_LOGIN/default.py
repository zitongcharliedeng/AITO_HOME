machine.wait_for_unit("display-manager.service")
import time; time.sleep(5)
machine.screenshot("user_sees_login_prompt")
