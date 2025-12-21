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
    ├── CREATE_NEW_FEATURE/
    │   ├── 1_DEFINE_USER_JOURNEY.sh
    │   ├── 2_IMPLEMENT_UNTIL_GREEN.sh
    │   ├── 3_WATCH_TEST_RUN.sh
    │   └── 4_LGTM_AND_COMMIT.sh
    │
    ├── flake.nix
    └── flake_modules/
        ├── USE_HARDWARE_CONFIG_FOR_MACHINE_/
        │   ├── HYPER_V.nix          # auto-generated
        │   ├── GPD_POCKET_4.nix     # auto-generated
        │   └── ...
        └── USE_SOFTWARE_CONFIG/
```

## What to Test

**Nix is declarative.** If `nixos-rebuild` succeeds, the declared config IS the system. Don't test what Nix already guarantees.

### DON'T TEST (Nix handles it)
- Configuration values (hostname, timezone, users, packages)
- File contents declared in Nix
- Service installation
- Anything that's a direct 1:1 mapping from declaration to system state

### DO TEST (runtime behavior)
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

### Test Helper Convention

```python
# Good - reads like speech
with subtest("terminal is pinned to left side"):
    ...

with subtest("user types hello and LLM responds"):
    ...

# Bad - testing what Nix already guarantees
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
