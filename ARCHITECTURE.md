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

## Access Strategy: Local-First, Not Remote Desktop

### Options Considered

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| **RustDesk (remote desktop)** | Real apps, no reimplementation | No offline access, depends on internet, accessibility concerns | ❌ Rejected |
| **PWA-only** | Works anywhere, offline cache | Can't enforce, just a viewer, have to rebuild everything | ❌ Rejected as primary |
| **Native NixOS + PWA secondary** | Full offline, enforcement, real apps | Phone is limited | ✅ Chosen |

### Why NOT Remote Desktop (RustDesk)

- **No offline access** - If internet is down, you have nothing
- **Latency** - Every keystroke over network
- **Accessibility** - Touch screen, resizing may be janky
- **Single point of failure** - Homelab down = dead

### Why NOT PWA as Primary

- **No enforcement** - Can just close the tab
- **Rebuild everything** - Superproductivity, terminal, etc. all need reimplementing
- **Still needs backend** - PWA alone can't do anything

### The Chosen Architecture: Local-First

```
PRIMARY: GPD Pocket 4 (NixOS) - ALWAYS WITH YOU
├── Full LifeOS running LOCALLY
├── Works OFFLINE
├── Superproductivity NATIVE
├── Terminal NATIVE
├── Enforcement NATIVE
└── Syncs to homelab when online

SECONDARY: Phone / Random Computer - LIMITED, THAT'S OK
├── Webapp (PWA-capable, cached)
├── Offline: read cached data, queue actions
├── Online: sync with homelab, view full data
└── Cannot enforce, just viewing/queueing
```

### Offline Sync Strategy

```
GPD Pocket 4 (offline)              Homelab
    │                                  │
    │ [full functionality locally]     │
    │                                  │
    └──── internet available ─────────▶│ bidirectional sync
                                       │
Phone (offline)                        │
    │                                  │
    │ [cached read-only + action queue]│
    │                                  │
    └──── internet available ─────────▶│ push queued actions, pull updates
```

**When offline on GPD:** Everything works. It's the primary device.
**When offline on phone:** Read cached schedule/tasks, queue actions (like "add task X"). Syncs when online.

### When to Use Each

| Situation | Device | Mode |
|-----------|--------|------|
| Normal daily use | GPD Pocket 4 | Full local |
| Quick check while out | Phone | Webapp (cached) |
| At library/cafe | GPD Pocket 4 | Full local |
| Emergency, no GPD | Phone → Homelab | Remote webapp |
| Gaming PC (Windows) | Browser → Homelab | Webapp view only |

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

## Silicon Cog (The Homelab)

The NixOS homelab IS Silicon Cog - the digital extension of the body.

**Everything lives here:**
- All photos (migrated from Google Photos)
- All instant replays
- All conversation history
- All project files
- The webapp
- The AI agent (Claude Code / PAI)

**Encrypted. Distributed. Owned.**

---

## Webapp ↔ AI Agent Connection

```
LOCAL (on NixOS machine):
┌─────────────┐     ┌─────────────┐
│  Webapp UI  │────▶│ Claude Code │  (same machine)
│  (browser)  │     │  (terminal) │  (unix socket or direct spawn)
└─────────────┘     └─────────────┘

REMOTE (phone, library, anywhere):
┌─────────────┐     ┌─────────────────────────────────────┐
│   Browser   │────▶│         NixOS Homelab               │
│  (anywhere) │HTTPS│  ┌─────────┐     ┌─────────────┐   │
└─────────────┘     │  │ Webapp  │────▶│ Claude Code │   │
                    │  └─────────┘     └─────────────┘   │
                    └─────────────────────────────────────┘
```

**Same UI everywhere. Claude Code only runs locally on homelab.**

---

## Remote Access (Zero Trust)

**Twingate / Tailscale / Cloudflare Tunnel:**
- No exposed ports
- Zero trust authentication
- Access homelab from anywhere
- Login required (private routes)

```
Phone in library
    │
    │ Twingate / Tailscale
    ▼
NixOS Homelab
    │
    │ Auth check
    ▼
LifeOS Webapp ←→ Claude Code
```

---

## Project Switching

Each project has its own context:

```
AITO: "Which project?"
You: "Working on PAI"

AITO: [loads PAI/.aito/context.md]
      [reads PAI/AGENTS.md]
      [conversation saved to PAI/.aito/history/]

You: "Switch to AITO_HOME"

AITO: [loads AITO_HOME/.aito/context.md]
      [different history, different context]
```

**Project context is per-repo. Agent adapts.**

---

## Bootstrap Priority

**Phase 1: NixOS Foundation (DO THIS FIRST)**
1. Get NixOS running (cloud instance initially, no physical homelab yet)
2. Everything encrypted
3. Basic webapp running
4. Claude Code accessible via webapp

**Phase 2: Migrate Data**
1. Export Google Photos → homelab
2. Set up backup to B2 (encrypted)
3. Conversation history storage

**Phase 3: Enforcement**
1. App restrictions on NixOS
2. Parental controls on secondary devices
3. Pavlok integration

**Phase 4: Full LifeOS**
1. GTD system (superproductivity or custom)
2. Daily log generation
3. Graphs and analytics

---

## Cloud vs Physical Homelab

**Initial (no physical homelab):**
```
Cloud Instance (DigitalOcean/Hetzner)
├── NixOS
├── Encrypted storage
├── Webapp + Claude Code
└── Backup to B2
```

**Eventually (physical homelab):**
```
Physical Machine (home)          Cloud Instance (backup)
├── NixOS                        ├── NixOS (replica)
├── All data (primary)    ──────▶├── Encrypted sync
├── Webapp + Claude Code         └── Failover
└── Backup to B2
```

**Cloud is temporary scaffolding until physical homelab exists.**

---

## Encryption Requirements

- All data at rest: encrypted (LUKS or similar)
- All data in transit: HTTPS / Wireguard
- Backups to B2: encrypted before upload (age/gpg)
- Credentials: agenix (NixOS-native secrets)

**If the cloud provider is compromised, they see only encrypted blobs.**

---

## Open Questions

- [ ] Instant replay: where does it fit? OS-level recording, saved to `/var/aito/replays/`?
- [ ] Superproductivity vs custom GTD in webapp?
- [ ] Which cloud provider for initial instance? (DigitalOcean? Hetzner?)
- [ ] Twingate vs Tailscale vs Cloudflare Tunnel for remote access?
- [ ] How to sync/replicate between cloud and eventual physical homelab?
