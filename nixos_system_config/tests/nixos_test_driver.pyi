"""Type stubs for NixOS test driver.

This file provides LSP support for NixOS test scripts.
The actual implementations are injected at runtime by the test driver.
"""

from typing import Any, Callable, ContextManager
from pathlib import Path

class Machine:
    """A NixOS virtual machine in a test."""

    name: str

    def is_up(self) -> bool:
        """Check if the machine is running."""
        ...

    def log(self, msg: str) -> None:
        """Log a message."""
        ...

    def nested(self, msg: str, attrs: dict[str, str] = {}) -> ContextManager[None]:
        """Create a nested log context."""
        ...

    def wait_for_unit(self, unit: str, user: str | None = None, timeout: int = 900) -> None:
        """Wait for a systemd unit to be active."""
        ...

    def get_unit_info(self, unit: str, user: str | None = None) -> dict[str, str]:
        """Get information about a systemd unit."""
        ...

    def get_unit_property(self, unit: str, property: str, user: str | None = None) -> str:
        """Get a specific property of a systemd unit."""
        ...

    def systemctl(self, q: str, user: str | None = None) -> tuple[int, str]:
        """Run systemctl with the given arguments."""
        ...

    def require_unit_state(self, unit: str, require_state: str = "active") -> None:
        """Assert that a unit is in the required state."""
        ...

    def execute(
        self,
        command: str,
        check_return: bool = True,
        check_output: bool = True,
        timeout: int | None = 900
    ) -> tuple[int, str]:
        """Execute a command and return (exit_code, output)."""
        ...

    def succeed(self, *commands: str, timeout: int | None = None) -> str:
        """Run commands, assert they succeed, return output."""
        ...

    def fail(self, *commands: str, timeout: int | None = None) -> str:
        """Run commands, assert they fail, return output."""
        ...

    def wait_until_succeeds(self, command: str, timeout: int = 900) -> str:
        """Retry command until it succeeds."""
        ...

    def wait_until_fails(self, command: str, timeout: int = 900) -> str:
        """Retry command until it fails."""
        ...

    def wait_for_shutdown(self) -> None:
        """Wait for the machine to shut down."""
        ...

    def get_tty_text(self, tty: str) -> str:
        """Get text content of a TTY."""
        ...

    def wait_until_tty_matches(self, tty: str, regexp: str, timeout: int = 900) -> None:
        """Wait until TTY content matches a regex."""
        ...

    def send_chars(self, chars: str, delay: float | None = 0.01) -> None:
        """Send characters to the VM console."""
        ...

    def wait_for_file(self, filename: str, timeout: int = 900) -> None:
        """Wait for a file to exist."""
        ...

    def wait_for_open_port(self, port: int, addr: str = "localhost", timeout: int = 900) -> None:
        """Wait for a TCP port to be open."""
        ...

    def wait_for_open_unix_socket(self, addr: str, is_datagram: bool = False, timeout: int = 900) -> None:
        """Wait for a Unix socket to be available."""
        ...

    def wait_for_closed_port(self, port: int, addr: str = "localhost", timeout: int = 900) -> None:
        """Wait for a TCP port to be closed."""
        ...

    def start_job(self, jobname: str, user: str | None = None) -> tuple[int, str]:
        """Start a systemd job."""
        ...

    def stop_job(self, jobname: str, user: str | None = None) -> tuple[int, str]:
        """Stop a systemd job."""
        ...

    def connect(self) -> None:
        """Connect to the machine."""
        ...

    def screenshot(self, filename: str) -> None:
        """Take a screenshot of the VM display."""
        ...

    def copy_from_host(self, source: str, target: str) -> None:
        """Copy a file from the host to the VM."""
        ...

    def copy_from_vm(self, source: str, target_dir: str = "") -> None:
        """Copy a file from the VM to the host."""
        ...

    def get_screen_text(self) -> str:
        """Get text from the VM screen using OCR."""
        ...

    def wait_for_text(self, regex: str, timeout: int = 900) -> None:
        """Wait for text to appear on screen (OCR)."""
        ...

    def wait_for_console_text(self, regex: str, timeout: int | None = None) -> None:
        """Wait for text to appear in the console."""
        ...

    def send_key(self, key: str, delay: float | None = 0.01, log: bool | None = True) -> None:
        """Send a key press to the VM."""
        ...

    def send_console(self, chars: str) -> None:
        """Send characters to the console."""
        ...

    def start(self, allow_reboot: bool = False) -> None:
        """Start the machine."""
        ...

    def shutdown(self) -> None:
        """Gracefully shut down the machine."""
        ...

    def crash(self) -> None:
        """Simulate a power failure."""
        ...

    def reboot(self) -> None:
        """Reboot the machine."""
        ...

    def wait_for_x(self, timeout: int = 900) -> None:
        """Wait for the X server to be ready."""
        ...

    def get_window_names(self) -> list[str]:
        """Get names of all X windows."""
        ...

    def wait_for_window(self, regexp: str, timeout: int = 900) -> None:
        """Wait for a window matching the regex."""
        ...

    def sleep(self, secs: int) -> None:
        """Sleep for a number of seconds."""
        ...

    def forward_port(self, host_port: int = 8080, guest_port: int = 80) -> None:
        """Forward a port from host to guest."""
        ...

    def block(self) -> None:
        """Block network traffic."""
        ...

    def unblock(self) -> None:
        """Unblock network traffic."""
        ...


# Global functions injected by test driver

def start_all() -> None:
    """Start all machines in parallel."""
    ...

def join_all() -> None:
    """Wait for all machines to shut down."""
    ...

def subtest(name: str) -> ContextManager[None]:
    """Context manager for grouping test logs."""
    ...

def retry(fn: Callable[[], Any], timeout: int = 900) -> Any:
    """Retry a function until it succeeds or times out."""
    ...

def create_machine(config: dict[str, Any]) -> Machine:
    """Dynamically create a new machine."""
    ...

def serial_stdout_on() -> None:
    """Enable serial output to stdout."""
    ...

def serial_stdout_off() -> None:
    """Disable serial output to stdout."""
    ...

def polling_condition(
    fun: Callable[[], bool] | None = None,
    *,
    seconds_interval: float = 2.0,
    description: str | None = None
) -> Callable[..., ContextManager[None]]:
    """Create a polling condition decorator/context manager."""
    ...


# Global variables injected by test driver

machine: Machine
"""The default machine (when only one exists)."""

machines: list[Machine]
"""List of all machines in the test."""

log: Any
"""Logger instance."""
