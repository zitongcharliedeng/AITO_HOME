# AGENTS.md

This is the only context file. Humans are agents too.

**This file contains philosophy and conventions only.** No implementation specs. The test names ARE the specs - putting specs here adds indirection.

This is AITO's home. The system IS AITO (AI Task Orchestrator). Not "AITO runs on the system" - the whole thing is one entity.

## Philosophy

**SCREAMING_SNAKE_CASE scripts are spells.** Human-readable intentions you can cast. Even if your LLM goes down, you search for the spell name and cast it yourself. The LLM is just autocomplete on steroids.

**Approval tests are the spec.** Golden masters capture human-perceivable output (screenshots, audio, structured text). If the output matches the golden, the experience is correct. Black box testing on human qualia. See: Llewellyn Falco's Approval Testing, Michael Feathers' Golden Master Testing.

**The LLM figures out implementation.** You describe the critical user journey. LLM writes code until outputs match goldens. You review diffs in PRs. Give LGTM. Only then merge.

**Tests bend to production, NOT the other way around.** Never modify production config to make tests pass. If the test fails, fix the test or fix the actual implementation - never add test-only hacks to production.

## Naming Conventions

- **SCREAMING_SNAKE_CASE** = Spells (APIs). The only way to interact with the system.
- **lowercase** = Implementation details. Never called directly.

## Test Naming

Test names are long descriptive sentences describing the EXPECTED STATE, not implementation steps.

**Good:** `TERMINAL_IS_VISIBLE_ON_LEFT_HALF_OF_SCREEN_SHOWING_HOME_DIRECTORY_IS_A_GIT_REPO`
**Bad:** `AFTER_LOGIN_TERMINAL_SHOWS_GIT_REPO` (implies action, not state)

The test should simply: boot → login → screenshot. If the system is correct, the expected state is already there. No workarounds in tests (opening apps, closing dialogs, pressing shortcuts).

## Code Style

**Use keyword arguments for clarity.** When calling functions, use `login(machine, password="password")` not `login(machine, "password")`.

**Comments are OK** if they accompany implementation details inside helper functions.

**Don't assemble things yourself.** Use existing well-maintained NixOS modules. If brightness/bluetooth/etc needs to work, find a module that handles it - don't cobble together services manually.

## Approval Testing Philosophy

**Test human-perceivable output.** The system is a visual desktop. Test what humans experience - screens, sounds, structured responses. Black box approach.

**Golden types:**
- **Screenshots** (.png) - what the user sees
- **Audio** (.wav) - what the user hears (future)
- **Text patterns** (regex) - structured LLM responses, skill procs

**Reproducible = same inputs → same output.** With locally-hosted LLMs (fixed weights, temperature=0), even AI responses are deterministic. Same input → same output → same golden.

### Approval Workflow

1. **No golden exists** → test runs, captures output, human must approve to create golden
2. **Golden exists, output matches** → test passes
3. **Golden exists, output differs** → test fails, human must approve change or reject

Goldens live in `approval_tests/TEST_NAME/goldens/`. Screenshots are committed to the PR branch for human review.

### Four-Step Workflow for Adding Features

1. **Describe the intention** - Write a test file named after what SHOULD happen. The name IS the spec.

2. **First run captures output** - No golden exists yet. Test runs, captures output. Test "fails" because there's nothing to compare against.

3. **Approve or reject** - You review the captured output. Does it match your intention? If yes, it becomes the golden. If no, LLM keeps iterating.

4. **Goldens prevent regression** - Future runs compare against approved goldens. Mismatch = failure. You review diff in PR. Approve new golden or reject the change.

### Why Goldens Over Assertions

- No brittle selectors or imperative checks
- Captures the WHOLE experience, not just what you thought to test
- Diffs are human-reviewable - you SEE/HEAR the regression
- The golden IS the spec - no translation layer

### What Nix Handles vs What Approval Tests Handle

**Nix guarantees declaratively:** hostname, timezone, packages, users, services installed. If `nixos-rebuild` succeeds, these are correct by definition.

**Approval tests verify:** What the human actually perceives. GUI layout, sounds, responses, the whole experience. These emerge at runtime and can only be observed, not declared.

## Agent Workflow Rules

**Only hand back when tests pass.** Don't give incomplete work to the human. Run tests, fix failures, then hand back.

**Source of truth is GitHub.** All changes go through PRs. Whether using agent, VS Code, or Vim - it all flows through GitHub.

**Local testing for speed.** Agents should know how to run tests locally:
```
nix build .#checks.x86_64-linux.TEST_NAME
```
Don't wait for GitHub Actions when you can iterate locally.

## First Time Setup

1. Download the NixOS graphical installer ISO
2. Boot from the ISO
3. Click through the installer - none of the settings matter:
   - Region, language, keyboard: pick anything
   - Username and password: pick anything
   - Desktop: select "No desktop"
   - Partitioning: use the defaults
4. Finish install, reboot, login with the installer user
5. Connect to internet
6. Run:
   ```
   nix-shell -p git
   git clone https://github.com/zitongcharliedeng/AITO_HOME.git .
   ~/nixos_system_config/BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh MY_NEW_MACHINE
   ```
7. Reboot
8. Login with `username` / `password` - you now have AITO with git available

The repo IS your home directory. The script auto-generates `MY_NEW_MACHINE.nix` with your hardware config. Machine names must be SCREAMING_SNAKE_CASE.
