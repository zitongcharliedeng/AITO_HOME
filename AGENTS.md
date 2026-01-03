# AGENTS.md

This is the only context file. Humans are agents too.

**This file contains philosophy and conventions only.** No implementation specs. The test names ARE the specs.

This is AITO's home. The system IS AITO (AI Task Orchestrator). Not "AITO runs on the system" - the whole thing is one entity.

---

## Core Philosophy

### Cog and Ito (The Mental Model)

- **Ito** = prefrontal cortex, conscious planning self, long-term eudaimonia
- **Cog** = body, reflexes, addictions, takes over when Ito is absent
- **AITO** = AI assistant that helps Ito control Cog
- **Ulysses Pacts** = pre-commitments that bind Cog when Ito isn't present

**Core Principle:** Build your body like software. Declarative. Changelogable. Testable. Rollbackable.

### The Home Directory IS the Git Repo

The user's home directory is literally this repository. Clone it, and you have the system. Push changes, and you're updating the system spec.

```
~/ = AITO_HOME/
├── AGENTS.md              (this file - philosophy)
├── nixos_system_config/   (NixOS flake)
└── [future: PAI, webapp, etc.]
```

**If it's not in git, it doesn't exist.** The system can roll back. Memory never deletes.

### Evict My Darlings: The Purity Principle

Modern AI tools create hidden state:
- `~/.claude/memory.json` - ephemeral memory that persists
- Dotfiles scattered across home
- Session history stored outside projects

**This is impure. This is wrong.**

**Rule: One Project = One Source of Truth**

```
CORRECT:
project-repo/
├── .aito/              (all AI context for THIS project)
│   ├── context.md
│   └── history/
└── [code]

WRONG:
~/.claude/memory.json           <- NO
~/.config/aito/global-memory    <- NO
```

**Why?**
1. Projects are portable - clone repo, get full context
2. No hidden state - everything in git is visible
3. No cross-contamination between projects
4. True rollback - `git reset --hard` actually resets EVERYTHING
5. Auditable - anyone can see why AI did what it did

---

## Naming Conventions

- **SCREAMING_SNAKE_CASE** = Spells (APIs). Human-readable intentions you can cast. Even if your LLM goes down, you search for the spell name and cast it yourself.
- **lowercase** = Implementation details. Never called directly.

**SCREAMING_SNAKE_CASE scripts are spells.** The LLM is just autocomplete on steroids.

---

## Testing Philosophy

### Approval Tests Are The Spec

Golden masters capture human-perceivable output (screenshots, audio, structured text). If the output matches the golden, the experience is correct. Black box testing on human qualia.

See: Llewellyn Falco's Approval Testing, Michael Feathers' Golden Master Testing.

### The LLM Figures Out Implementation

You describe the critical user journey. LLM writes code until outputs match goldens. You review diffs in PRs. Give LGTM. Only then merge.

### Tests Bend to Production, NOT the Other Way Around

Never modify production config to make tests pass. If the test fails, fix the test or fix the actual implementation - never add test-only hacks to production.

### Test Naming

Test names are long descriptive sentences describing the EXPECTED STATE, not implementation steps.

**Good:** `HOME_DIRECTORY_IS_GIT_REPO_AFTER_REBOOT`
**Bad:** `TEST_GIT_REPO_EXISTS` (vague, implementation-focused)

The test should simply: boot -> check state. If the system is correct, the expected state is already there.

### What Nix Handles vs What Tests Handle

**Nix guarantees declaratively:** hostname, timezone, packages, users, services. If `nixos-rebuild` succeeds, these are correct by definition.

**Tests verify:** Emergent runtime behavior. Things that can only be observed, not declared.

### Approval Workflow

1. **No golden exists** -> test runs, captures output, human must approve to create golden
2. **Golden exists, output matches** -> test passes
3. **Golden exists, output differs** -> test fails, human must approve change or reject

### Golden Types

- **Screenshots** (.png) - what the user sees
- **Text output** (.txt) - command output, logs
- **Structured data** (.json) - API responses

---

## Code Style

**Use keyword arguments for clarity.** `login(machine, password="password")` not `login(machine, "password")`

**No comments or docstrings.** Function names and parameters should be self-explanatory. If you need a comment, your naming is bad.

**Minimal code to pass tests.** Smallest amount of lines needed. Don't over-engineer.

**99% imports, 1% glue.** All code is imports with good names. No bespoke code. No reinventing wheels. Unix philosophy: use pre-made, well-maintained modules.

---

## Agent Workflow Rules

**Only hand back when tests pass.** Don't give incomplete work to the human.

**Source of truth is GitHub.** All changes go through PRs. CI gates everything.

**Local testing for speed:**
```
nix build .#checks.x86_64-linux.TEST_NAME
```
Don't wait for GitHub Actions when you can iterate locally.

---

## Development Workflow

**Enter the devShell before doing any work:**
```
cd ~/nixos_system_config
nix develop
```

This automatically:
- Installs git pre-commit hooks that run `nix flake check`
- Blocks commits until all tests pass

**Pre-commit hooks block bad commits.** Every commit runs the full test suite.

**CI runs on PRs.** GitHub Actions runs tests. PRs cannot merge until checks pass.

---

## First Time Setup

1. Download the AITO_HOME installer ISO from GitHub Releases
2. Boot from the ISO
3. Run: `./INSTALL_SYSTEM.sh MACHINE_NAME` (available machines are listed)
4. Reboot
5. Login with `username` / `password` - your home directory IS the git repo

The installer ISO includes prebuilt system closures for all machines. No network required. The install is a pure offline operation from the ISO's nix store.

---

## Architecture: Headless NixOS + SSH + Claude

**What we need:**
- Terminal (TTY or SSH)
- Git
- Claude Code (PAI)

**What we DON'T need:**
- Display manager (GDM, SDDM, etc.)
- Desktop environment (GNOME, KDE, etc.)
- GUI applications

The web frontend (when built) runs elsewhere or is accessed remotely. The NixOS machine is pure infrastructure - a terminal you SSH into.

**Why?**
- NixOS hardware support for GUIs is inconsistent (brightness, rotation, etc.)
- We don't need GUI - we have a web frontend
- Simpler = fewer things to break
- SSH works everywhere

---

## Enforcement Hierarchy

1. **Automated enforcement** (NixOS, CI) - ideal
2. **External enforcement** (Cold Turkey key with partner, Pavlok)
3. **Logged manual intervention** (documented, verified)
4. **Time tracking** (catches everything, safety net)

If it can't be enforced -> find a way, or don't bother documenting.

---

## Daily Review (Ito's Conscious Window)

```
Morning (as Ito):
  -> Review time tracking from yesterday
  -> Identify where Cog took over
  -> Talk to AITO about patterns
  -> Adjust pacts / add restrictions
  -> Commit changes to git
  -> Changelog updated
```

---

## Data Separation

| Type | Location | Mutable? | Rollbackable? |
|------|----------|----------|---------------|
| NixOS config | git repo | Yes | Yes |
| Conversation history | `/var/aito/conversations/` | **Append-only** | **Never delete** |
| Photos/media | `/var/aito/media/` | **Append-only** | **Never delete** |

**Conversation history is sacred.** System can roll back. Memory never deletes.
