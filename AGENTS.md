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
    ├── BUILD_NIXOS_FROM_FLAKE.sh
    │
    ├── CREATE_NEW_FEATURE/
    │   ├── 1_DEFINE_USER_JOURNEY.sh
    │   ├── 2_IMPLEMENT_UNTIL_GREEN.sh
    │   ├── 3_WATCH_TEST_RUN.sh
    │   └── 4_LGTM_AND_COMMIT.sh
    │
    ├── flake.nix                       # lowercase = implementation
    ├── flake_modules/
    └── tests/
```

## Test Helper Convention

```nix
# Good - reads like speech
terminal.exists()
terminal.isPinnedLeft()
terminal.cannotBeClosed()

# Bad - leaks implementation
machine.succeed("pgrep -x ghostty")
```

## First Milestone

Boot minimal ISO → `BUILD_NIXOS_FROM_FLAKE.sh` → system boots with user `username`.
