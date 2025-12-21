machine.wait_for_unit("multi-user.target")

with subtest("hostname is AITO"):
    result = machine.succeed("hostname")
    assert "AITO" in result, f"expected AITO, got {result}"

with subtest("timezone is UTC"):
    result = machine.succeed("timedatectl show --property=Timezone --value")
    assert "UTC" in result, f"expected UTC, got {result}"

with subtest("user can login"):
    machine.succeed("id username")

with subtest("user can sudo"):
    result = machine.succeed("groups username")
    assert "wheel" in result, f"expected wheel group, got {result}"
