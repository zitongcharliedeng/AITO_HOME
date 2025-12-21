# AGENTS.md

This is the only context file. Humans are agents too.

This is AITO's home. The system IS AITO (AI Task Orchestrator). Not "AITO runs on the system" - the whole thing is one entity.

## Philosophy

**SCREAMING_SNAKE_CASE scripts are spells.** Human-readable intentions you can cast. Even if your LLM goes down, you search for the spell name and cast it yourself. The LLM is just autocomplete on steroids.

**Tests are specs written in human speech.** No implementation details (ghostty, i3, wayland). Helper functions like `terminal.exists()`, `terminal.isPinnedLeft()`. The test reads like a conversation.

**The LLM figures out implementation.** You describe the critical user journey. LLM writes code until tests pass. You watch the test run visually. Verify it's green for the right reason. Give LGTM. Only then commit.

## Naming Conventions

- **SCREAMING_SNAKE_CASE** = Spells (APIs). The only way to interact with the system.
- **lowercase** = Implementation details. Never called directly.

## Directory Structure

```
AITO_HOME/
├── AGENTS.md
│
└── nixos_system_config/
    ├── BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh
    │
    ├── flake.nix
    ├── flake_modules/
    │   ├── USE_HARDWARE_CONFIG_FOR_MACHINE_/
    │   │   ├── HYPER_V.nix          # auto-generated
    │   │   └── ...
    │   └── USE_SOFTWARE_CONFIG/
    │
    └── runtime_tests/
        ├── SYSTEM_BOOTS.nix         # test definition
        └── SYSTEM_BOOTS.py          # emergent behavior checks
```

## Two Types of Specs

**The Nix config IS the declarative spec.** If `nixos-rebuild` succeeds, the declared config IS the system. Hostname, timezone, packages, users - Nix guarantees these.

**Runtime tests verify emergent behavior.** Things that only exist when the system runs - GUI state, service responses, LLM interactions. These can't be declared, only observed.

### Nix Handles (declarative spec)
- Configuration values (hostname, timezone, users, packages)
- File contents
- Service installation
- Anything that's a 1:1 mapping from declaration to system state

### Runtime Tests Handle (emergent behavior)
- **End-to-end scripts work** - the build script produces a bootable system
- **Services respond** - not "is nginx installed" but "does nginx serve the page"
- **GUI behavior** - window positioning, focus, visual state
- **Non-deterministic interactions** - LLM responds appropriately
- **Multi-component interactions** - component A talks to component B

### LLM Response Testing
When testing LLM responses (non-deterministic), use an LLM as the validator:
- Test sends input to the system LLM
- Response is evaluated by a separate LLM judge
- Judge checks: "Does this response satisfy the user intent?"

### Runtime Test Convention

```python
# Good - tests emergent runtime behavior
with subtest("terminal is pinned to left side"):
    ...

with subtest("user types hello and LLM responds"):
    ...

# Bad - Nix already guarantees this declaratively
with subtest("hostname is AITO"):
    ...
```

## First Time Setup

1. Download the NixOS graphical installer ISO
2. Boot from the ISO
3. Click through the installer - none of the settings matter:
   - Region, language, keyboard: pick anything
   - Username and password: pick anything
   - Desktop: select "No desktop"
   - Partitioning: use the defaults
4. Finish install, reboot, login
5. Connect to internet
6. Run:
   ```
   nix-shell -p git
   git clone https://github.com/zitongcharliedeng/AITO_HOME.git ~
   ~/nixos_system_config/BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh MY_NEW_MACHINE
   ```
7. Reboot
8. Login with `username` / `password` - you now have AITO

The repo IS your home directory. The script auto-generates `MY_NEW_MACHINE.nix` with your hardware config. Machine names must be SCREAMING_SNAKE_CASE.
