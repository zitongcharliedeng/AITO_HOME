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

## LifeOS: One Interface That IS The Desktop

**Epiphany:** LifeOS is not an app you open. It IS the desktop. Everything else runs inside it or is blocked.

```
┌─────────────────────────────────────────────────────────────────┐
│                     LIFEOS (the only thing you see)             │
│                                                                 │
│   ┌─────────────────┐  ┌─────────────────────────────────────┐ │
│   │                 │  │                                     │ │
│   │   AITO CHAT     │  │  RIGHT NOW: "Work on PAI project"   │ │
│   │                 │  │                                     │ │
│   │  "Hi, talk      │  │  [Embedded Terminal]                │ │
│   │   to me"        │  │                                     │ │
│   │                 │  │  [Superproductivity - embedded]     │ │
│   │  Entry point    │  │                                     │ │
│   │  for all        │  │  RESTRICTIONS ACTIVE:               │ │
│   │  intentions     │  │  • YouTube blocked until 6pm       │ │
│   │                 │  │  • Games blocked until tasks done   │ │
│   │                 │  │                                     │ │
│   └─────────────────┘  └─────────────────────────────────────┘ │
│                                                                 │
│   Everything else: launched through this interface, or blocked. │
└─────────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **One interface** - Single view you look at all day
2. **Embeds existing tools** - Don't remake superproductivity, embed it
3. **Context-aware** - Shows right tools at right time
4. **Enforced** - NixOS blocks what browser can't
5. **NixOS > Browser** - Browser is limited; NixOS controls the whole system

### Why NixOS, Not Just Browser

| Browser can... | NixOS can... |
|----------------|--------------|
| Display UI | Display UI |
| Run web apps | Run ANY apps |
| | Block apps at OS level |
| | Control window manager |
| | Restrict at system level |
| | Manage hardware |

**Browser is the interface. NixOS is the enforcer.**

### Don't Rebuild, Embed

- **Superproductivity** → embed web version, don't remake
- **Terminal** → embed xterm.js or native terminal
- **Calendar** → embed existing solution

**Future:** AI builds bespoke tools. We're not there yet. Use what exists.

### Public vs Private

**Public daemon site:** Simple webpage, anyone can view schedule, ask AITO about philosophy
**Private LifeOS:** Full desktop session, embedded tools, enforcement active

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

## Access Strategy: NixOS Everywhere

### Options Considered

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| **RustDesk (remote desktop)** | Real apps, no reimplementation | No offline access, latency, SPOF | ❌ Rejected |
| **PWA + NixOS hybrid** | Access from phone | Two systems to maintain, phone can't enforce | ❌ Rejected |
| **NixOS on all devices** | Same config everywhere, full enforcement, offline works | Need NixOS-compatible devices | ✅ Chosen |

### Why NOT Remote Desktop (RustDesk)

- **No offline access** - If internet is down, you have nothing
- **Latency** - Every keystroke over network
- **Single point of failure** - Homelab down = dead

### Why NOT Phone/PWA

- **No enforcement** - Can just close the tab
- **Two systems** - NixOS + PWA = more complexity
- **Phone is a leak** - Can't control it declaratively

### The Chosen Architecture: NixOS Everywhere

**One flake. Multiple hardware configs. Same software.**

```
AITO_HOME/nixos_system_config/
├── flake.nix
└── flake_modules/
    ├── USE_SOFTWARE_CONFIG/        ← SAME for all devices
    │   └── (LifeOS, enforcement, apps)
    │
    └── USE_HARDWARE_CONFIG_FOR_MACHINE_/
        ├── GPD_POCKET_4.nix        ← Device-specific
        ├── DESKTOP.nix
        ├── LAPTOP.nix
        └── CLOUD_INSTANCE.nix
```

**Every device runs NixOS:**
- Same software config
- Same enforcement
- Same LifeOS interface
- Works offline
- Syncs data when online

### Sync Strategy

```
Device A (NixOS)                Device B (NixOS)
    │                               │
    │ [full local functionality]    │ [full local functionality]
    │                               │
    └───────── Syncthing ──────────┘
              (or similar)
                   │
                   ▼
             Homelab/Cloud
             (backup + sync hub)
```

**All devices are equal.** No primary/secondary. Whichever you're using IS the primary.

### What About Phone?

**Current:** Keep phone for camera + cellular only. Not part of LifeOS.

**Future:** When Linux phones are viable (PinePhone, or GPD with cellular), replace phone with another NixOS device.

**The phone is not part of the system.** It's a temporary necessity, heavily restricted, not trusted.

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

## Critical Decision: NixOS Frontend vs Web App Frontend

### The Trade-off

| Factor | NixOS Desktop | Web App (any OS host) |
|--------|---------------|----------------------|
| **System restrictions** | ✅ Full control - block apps, control WM | ❌ Can only restrict via external tools (Cold Turkey) |
| **Hardware support** | ❌ Brightness, rotation, etc. often broken | ✅ Host OS handles it natively |
| **Runs on any device** | ❌ Only NixOS devices | ✅ Anything with a browser |
| **Offline capability** | ✅ Fully local | ⚠️ PWA can cache, but limited |
| **Testability** | ✅ NixOS VM screenshot tests | ✅ Browser screenshot tests |
| **Maintenance** | ❌ Must maintain NixOS configs per device | ✅ One web app, runs anywhere |
| **PAI/AI hosting** | Runs locally or connects to server | Requires server (can be cloud) |

### What Matters More?

**If RESTRICTIONS matter most:** NixOS Desktop
- Can block at OS level
- Can't bypass by opening another app
- Full control over window manager

**If AVAILABILITY matters most:** Web App
- Works on any device with browser
- Hardware just works (host OS handles it)
- One interface everywhere
- Lock down host OS externally (Cold Turkey, parental controls)

### The Hybrid Answer

```
BACKEND (NixOS server - cloud first, then homelab):
├── Hosts LifeOS web app
├── Hosts PAI
├── Stores all data
└── No hardware issues (server)

FRONTEND (Web app, any device):
├── Host OS = whatever works (Windows, Ubuntu, macOS)
├── Host OS locked down (Cold Turkey, Screen Time, etc.)
├── Browser = only allowed app
├── Browser fullscreen = LifeOS
└── Hardware works because host OS supports it

OFFLINE (Buffer mode):
├── PWA caches the interface
├── Can capture notes, drawings locally
├── Syncs when online
└── PAI not available offline (acceptable?)
```

### Decision Needed

**Question:** Is "PAI not available offline" acceptable?

- **If YES:** Web app frontend is simpler. Lock down any device. Done.
- **If NO:** Need local AI capability, which means NixOS (or complex local setup).

### Current Recommendation

**Go Web App frontend.** Reasons:
1. Hardware just works
2. Runs anywhere
3. Lock down via Cold Turkey/parental controls (good enough)
4. PAI on cloud server (internet is the bottleneck anyway, as you said)
5. PWA for offline buffer (capture, sync later)

**Accept:** PAI needs internet. That's OK. Internet is already the bottleneck for everything.

---

## Open Questions

- [ ] Instant replay: where does it fit? OS-level recording, saved to `/var/aito/replays/`?
- [ ] Superproductivity vs custom GTD in webapp?
- [ ] Which cloud provider for initial instance? (DigitalOcean? Hetzner?)
- [ ] Twingate vs Tailscale vs Cloudflare Tunnel for remote access?
- [ ] How to sync/replicate between cloud and eventual physical homelab?
- [ ] Is "PAI not available offline" acceptable? (Affects architecture choice)

---

## Evict My Darlings: The Purity Principle

### The Problem

Modern AI tools (Claude, OpenCode, Cursor) create hidden state:
- `~/.claude/memory.json` - "ephemeral memory" that persists
- Dotfiles scattered across home directory
- Session history stored outside projects
- "Remembering" things outside of git

**This is impure. This is wrong.**

### The Rule: One Project = One Source of Truth

```
CORRECT:
project-repo/
├── .aito/              (all AI context for THIS project)
│   ├── context.md      (what AI needs to know)
│   ├── history/        (conversation logs, IN GIT)
│   └── decisions.md    (why we did what we did)
├── ARCHITECTURE.md
└── [code]

WRONG:
~/.claude/memory.json           ← NO
~/.opencode/sessions/           ← NO
~/.config/aito/global-memory    ← NO
```

### Why?

1. **Projects are portable** - Clone repo, get full context. Nothing external.
2. **No hidden state** - Everything affecting behavior is visible in git.
3. **No cross-contamination** - Project A's decisions don't leak to Project B.
4. **True rollback** - `git reset --hard` actually resets EVERYTHING.
5. **Auditable** - Anyone can see why AI did what it did.

### What Dies

- Claude's ephemeral memory
- OpenCode's session persistence
- Any dotfile that stores "learned preferences"
- Any state that survives `rm -rf project && git clone`

### What Lives

- In-repo context (`.aito/`, `AGENTS.md`, `ARCHITECTURE.md`)
- Git history
- Explicit documentation

### Implementation

When PAI runs:
1. Read context ONLY from current project repo
2. Write history ONLY to current project repo  
3. NO access to global state, dotfiles, or cross-project memory
4. Each `cd` to a new project = fresh context, read from THAT repo

**If it's not in git, it doesn't exist.**

---

## Firm Decision: Web App Frontend

**Date: 2024-12-28**

NixOS = implementation hell. Web = agnostic, swappable, future-proof.

### What LifeOS Is

A **single-page web app**. Two panels:
- Left: AITO chat
- Right: Tasks + schedule

That's it. Not an OS. A dashboard.

### What LifeOS Is NOT

- A NixOS desktop environment
- A tiling window manager
- A replacement for native apps
- Complex

### Backend

Hetzner VPS running NixOS:
- Encrypted
- Hosts the web app
- Hosts PAI
- All data in git or encrypted storage
- SSH access
- Web access via browser

### The Stack

```
[Any Device] ──HTTPS──▶ [Hetzner VPS]
   Browser                  NixOS
   Fullscreen               ├── Web App (the UI)
   = LifeOS                 ├── PAI (Claude Code)
                            └── Data (git repos, encrypted)
```

### Lock Down Host Device

The device running the browser is locked down externally:
- Windows: Cold Turkey Blocker
- macOS: Screen Time
- Linux: whatever works
- Phone: Parental controls

Browser is the only allowed app. Browser fullscreen shows LifeOS.

---

