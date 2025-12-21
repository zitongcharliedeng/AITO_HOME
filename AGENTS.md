# AGENTS.md

This is the only context file. Humans are agents too.

This is AITO's home. The system IS AITO (AI Task Orchestrator). Not "AITO runs on the system" - the whole thing is one entity.

## Philosophy

**SCREAMING_SNAKE_CASE scripts are spells.** Human-readable intentions you can cast. Even if your LLM goes down, you search for the spell name and cast it yourself. The LLM is just autocomplete on steroids.

**Screenshot tests are the spec.** The screen IS the human experience. A screenshot captures exactly what a human would see. If the screenshot matches the golden, the experience is correct. Black box testing on human qualia.

**The LLM figures out implementation.** You describe the critical user journey as a sequence of screenshots. LLM writes code until screenshots match goldens. You review visual diffs in PRs. Give LGTM. Only then merge.

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
    └── screenshot_tests/
        ├── JOURNEY_NAME.nix         # test definition
        ├── JOURNEY_NAME.py          # actions to reach each screenshot
        └── goldens/
            └── JOURNEY_NAME/
                ├── 01_first_state.png
                ├── 02_after_action.png
                └── ...
```

## Screenshot Testing Philosophy

**Everything is a screenshot test.** The system is a visual desktop. The output is the screen. Test what humans experience.

**Reproducible = same inputs → same screenshot.** With locally-hosted LLMs (fixed weights, temperature=0), even AI responses are deterministic. Same input produces same screen state produces same screenshot.

**The workflow:**
1. Dev makes change
2. Test runs, captures screenshots at each journey step
3. Compares against golden PNGs
4. Mismatch → test fails, shows visual diff
5. Dev proposes new goldens if change is intentional
6. You review visual diff in PR - "does this still look right?"
7. Approve → new goldens become the spec

**Why screenshots over assertions:**
- No brittle selectors or imperative checks
- Captures the WHOLE experience, not just what you thought to test
- Diffs are human-reviewable - you SEE the regression
- The golden IS the spec - no translation layer

**Skills "proc" visually.** When a skill triggers (like SELF_IMPROVE), it shows on screen. The screenshot captures the proc indicator. No need to test internal state - if it shows correctly, it works.

### What Nix Handles vs What Screenshots Handle

**Nix guarantees declaratively:** hostname, timezone, packages, users, services installed. If `nixos-rebuild` succeeds, these are correct by definition.

**Screenshots verify:** What the human actually sees. GUI layout, responses, visual feedback, the whole experience. These emerge at runtime and can only be observed, not declared.

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
   rm -rf ~/* ~/.*  # Clear installer's home (backup anything you need first)
   git clone https://github.com/zitongcharliedeng/AITO_HOME.git .
   ~/nixos_system_config/BUILD_NIXOS_FROM_FLAKE_FOR_MACHINE_.sh MY_NEW_MACHINE
   ```
7. Reboot
8. Login with `username` / `password` - you now have AITO with git available

The repo IS your home directory. The script auto-generates `MY_NEW_MACHINE.nix` with your hardware config. Machine names must be SCREAMING_SNAKE_CASE.
