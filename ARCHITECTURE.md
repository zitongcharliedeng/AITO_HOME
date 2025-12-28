# AITO / LifeOS Architecture

## The Philosophy

**Cog and Ito:**
- **Ito** = prefrontal cortex, conscious planning self, long-term eudaimonia
- **Cog** = body, reflexes, addictions, takes over when Ito is absent
- **Alto/AITO** = AI assistant that helps Ito control Cog
- **Ulysses Pacts** = pre-commitments that bind Cog when Ito isn't present

**Core Principle:** Build your body like software. Declarative. Changelogable. Testable. Rollbackable.

---

## System Architecture (Brain Model)

```
┌─────────────────────────────────────────────────────────────────┐
│                          TELOS                                  │
│                  (ultimate purpose, north star)                 │
│                  Everything below serves this                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      COMMUNICATION                              │
│         Text / Conversation / Drawings / Voice                  │
│              (how Ito talks to the system)                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      BASAL GANGLIA                              │
│                   (task scheduling)                             │
│                                                                 │
│  • Task queue                                                   │
│  • Prioritization                                               │
│  • Planning / scheduling                                        │
│  • Reminders                                                    │
│  • Triggers (time, event, location)                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        NEOCORTEX                                │
│                    (memory / knowledge)                         │
│                                                                 │
│  • All photos (not Google - self-hosted)                        │
│  • Instant replays                                              │
│  • Daily logs (auto-generated)                                  │
│  • Associations (photo ↔ log entry ↔ location ↔ task)           │
│  • Searchable life history                                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         CHAINS                                  │
│               (control over physical body)                      │
│                                                                 │
│  • Today: Pavlok, parental controls, auto-shutdown              │
│  • Future: genome editing, neural interface, direct control     │
│  • Extensible - new chains plug in as technology advances       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation: NixOS + Webapp (Timeline C)

**Decision:** Use BOTH NixOS and Webapp together.

```
┌─────────────────────────────────────────┐
│         WEBAPP (interface layer)        │
│   • Define tasks, schedule, pacts       │
│   • Chat with AITO                      │
│   • View from any device                │
│   • Public daemon site (read-only)      │
│   • Private dashboard (logged in)       │
└────────────────┬────────────────────────┘
                 │ syncs / embedded
                 ▼
┌─────────────────────────────────────────┐
│    NixOS on GPD Pocket 4 (primary)      │
│   • ENFORCES the rules                  │
│   • Pins the dashboard (always visible) │
│   • Restricts apps/times                │
│   • Source of truth for enforcement     │
│   • Backend + Frontend in one           │
└─────────────────────────────────────────┘
```

**Why both:**
- NixOS = enforcement (teeth, can't bypass)
- Webapp = accessibility (view from phone, public daemon)
- Phone becomes read-only peripheral, not the brain

---

## Repository Structure

```
AITO_HOME/                      (this repo - git, declarative, rollbackable)
│
├── nixos_system_config/        NixOS flake
│   ├── flake.nix
│   └── flake_modules/
│       ├── USE_SOFTWARE_CONFIG/
│       └── USE_HARDWARE_CONFIG_FOR_MACHINE_/
│
├── lifeos-webapp/              (submodule - versioned separately)
│   └── [SvelteKit + Bun app]
│
├── pai/                        (submodule - AI assistant config)
│
├── ARCHITECTURE.md             (this file)
└── AGENTS.md                   (coding conventions)
```

---

## Data Separation

| Type | Location | Mutable? | Rollbackable? |
|------|----------|----------|---------------|
| NixOS config | git repo | Yes | Yes |
| Webapp code | git submodule | Yes | Yes |
| PAI config | git submodule | Yes | Yes |
| Conversation history | `/var/aito/conversations/` | **Append-only** | **Never delete** |
| Photos/media | `/var/aito/media/` | **Append-only** | **Never delete** |
| Daily logs | `/var/aito/logs/` | **Append-only** | **Never delete** |

**Conversation history is sacred.** System can roll back. Memory never deletes.

---

## LifeOS Webapp UI

```
┌─────────────────────────────────────────────────────────────────┐
│                    LIFEOS / DAEMON human 3.0                    │
├─────────────────────────┬───────────────────────────────────────┤
│                         │  CHANGELOG                            │
│      AITO CHAT          │  "carbon cog not brush teeth,         │
│                         │   ramped shock collar to 150v"        │
│   "Hi, talk to me"      │                                       │
│                         │  SCHEDULE (M T W T F S S)             │
│   Entry point to        │  ┌─────┬─────┬─────┐                  │
│   convert intentions    │  │Game │Study│Climb│                  │
│   → deterministic       │  ├─────┼─────┼─────┤                  │
│   rules via silicon     │  │Eat  │Work │Curry│                  │
│                         │  └─────┴─────┴─────┘                  │
│                         │                                       │
│   [✓] [≡]               │  see graphs ▼                         │
└─────────────────────────┴───────────────────────────────────────┘
```

**Public view:** Anyone can see schedule, ask AITO about philosophy
**Private view:** Full control, mutate schedule, discipline Cog

---

## Manual Interventions (Backlog for Automation)

Things currently requiring human willpower, to eventually automate:

- [ ] Avoiding sugar/carbs (manual willpower)
- [ ] Cold Turkey on Windows (needs key with accountability partner)
- [ ] Phone restrictions (needs parental control app)
- [ ] Wake-up verification (QR code scanning)

When Ito has conscious time → review backlog → automate next item → expand Ulysses pacts

---

## Hardware Strategy

**Primary device:** GPD Pocket 4 running NixOS
**Phone:** Kept for camera + cellular, heavily restricted, read-only LifeOS access
**Future:** Ditch phone when Linux devices have cellular + good cameras

---

## Enforcement Hierarchy

1. **Automated enforcement** (NixOS, n8n) - ideal
2. **External enforcement** (Cold Turkey key with partner, Pavlok)
3. **Logged manual intervention** (documented, verified in daily review)
4. **Time tracking** (catches everything, the safety net)

If it can't be enforced → find a way, or don't bother documenting.

---

## Daily Review (Ito's Conscious Window)

```
Morning (as Ito):
  → Review time tracking from yesterday
  → Identify where Cog took over
  → Talk to AITO about patterns
  → Adjust pacts / add restrictions
  → Commit changes to git
  → Changelog updated
```

---

## Open Questions

- [ ] Instant replay: where does it fit? OS-level recording, saved to `/var/aito/replays/`?
- [ ] How does webapp sync with NixOS enforcement? n8n? Direct API?
- [ ] Phone parental controls: which app? How to give AITO the key?
- [ ] Superproductivity vs custom GTD in webapp?
