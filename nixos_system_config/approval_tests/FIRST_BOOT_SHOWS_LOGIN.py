# Wait for system to be ready
machine.wait_for_unit("multi-user.target")

# FIRST_BOOT_SHOWS_LOGIN: After boot, user sees login prompt
machine.screenshot("login_prompt")
