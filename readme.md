
# 🎥 XAI Advanced Third Person Camera — GoldSrc / CS 1.6 / AMX Mod X

[![Version](https://img.shields.io/badge/version-2.2.1-5865F2.svg)](https://github.com/xansuz/GoldSrc-Advanced-Thirdperson)
[![AMX Mod X](https://img.shields.io/badge/AMX%20Mod%20X-AMXX-orange.svg)](https://www.amxmodx.org/)
[![Engine](https://img.shields.io/badge/engine-GoldSrc-brightgreen.svg)]()
[![Language](https://img.shields.io/badge/language-Pawn-8A2BE2.svg)]()
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)
[![Repository](https://img.shields.io/badge/GitHub-XAI--System-black.svg)](https://github.com/xansuz/GoldSrc-Advanced-Thirdperson)

> **Advanced Third Person Camera Plugin for GoldSrc and Counter-Strike 1.6**
>
> A modular AMX Mod X / AMXX third-person camera plugin with **3 dynamic camera modes**, per-player camera state, real-time `TraceLine` wall collision handling, direct console/chat commands, runtime CVAR control, automatic camera lifecycle management and optional `xai_main_menu` integration.

**Repository:** https://github.com/xansuz/GoldSrc-Advanced-Thirdperson  
**Developer:** [@xansuz](https://github.com/xansuz)  
**Current Plugin Version:** `2.2.1`

---

## ⭐ What Is XAI Advanced Third Person Camera?

**XAI Advanced Third Person Camera** is a standalone and modular **AMX Mod X / AMXX third-person camera plugin for GoldSrc**, designed primarily for **Counter-Strike 1.6 (CS 1.6)** and compatible GoldSrc server environments.

The plugin replaces the player's normal view attachment with a controlled camera entity when a third-person mode is active.

It provides:

- 🎥 3 distinct camera perspectives
- 👤 independent camera state for every player
- 🧱 real-time `TraceLine` camera collision handling
- 🔄 camera cleanup and recreation during player lifecycle events
- 🎮 console and chat controls
- ⚙️ dynamic CVAR configuration
- 🧩 optional XAI main-menu integration
- 🛡️ no forced client `config.cfg` modification
- 📦 no external camera model package required
- 🧱 standalone operation when `xai_main_menu` is unavailable

The goal is a **clean, reusable and independently deployable third-person camera component** rather than a feature that requires the entire XAI framework.

---

# 🚀 Highlights

| Feature | Status |
| :--- | :---: |
| GoldSrc camera system | ✅ |
| Counter-Strike 1.6 focused | ✅ |
| AMX Mod X plugin | ✅ |
| Pawn source included | ✅ |
| Precompiled `.amxx` included | ✅ |
| 3 camera perspectives | ✅ |
| First-person fallback | ✅ |
| Per-player camera state | ✅ |
| Real-time camera update | ✅ |
| TraceLine wall collision | ✅ |
| Runtime camera padding | ✅ |
| Camera cleanup on death | ✅ |
| Camera recreation after spawn | ✅ |
| Camera cleanup on disconnect | ✅ |
| Chat commands | ✅ |
| Console commands | ✅ |
| Direct mode selection | ✅ |
| Optional XAI menu integration | ✅ |
| Standalone mode | ✅ |
| Forced client config modification | ❌ |
| External camera asset requirement | ❌ |

---

# 🎥 Camera Modes

The plugin internally supports four states:

```text
MODE 0 = First Person / Camera OFF
MODE 1 = Close Shoulder
MODE 2 = Tactical
MODE 3 = Cinematic Front
```

The cycle command follows:

```text
0 → 1 → 2 → 3 → 0
```

---

## 0️⃣ Mode 0 — First Person

Normal GoldSrc / player view.

```text
Camera: OFF
```

When Mode 0 is selected, the plugin removes the custom camera entity and restores the player's normal view.

---

## 1️⃣ Mode 1 — Close Shoulder

A close third-person perspective designed for normal gameplay.

Default values:

```text
Distance: 88.0
Height:   24.0
```

Conceptually:

```text
        CAMERA
           \
            \
          PLAYER
            ↑
         LOOK DIR
```

This is the closest of the two rear-facing camera modes.

---

## 2️⃣ Mode 2 — Tactical

A wider third-person perspective that places the camera farther from the player.

Default values:

```text
Distance: 176.0
Height:    36.0
```

This provides a wider field of view around the player and is useful when a broader gameplay perspective is desired.

---

## 3️⃣ Mode 3 — Cinematic Front

A front-facing cinematic camera configuration.

Default values:

```text
Distance: 88.0
Height:   24.0
```

The camera direction is reversed by approximately:

```text
180°
```

and the pitch is inverted so that the camera faces the character from the opposite side.

This mode is intended for a front-facing / cinematic third-person experience.

---

# 🧱 Real-Time Wall Collision Protection

One of the most important parts of the plugin is its camera geometry handling.

The camera does not simply move to a fixed location behind the player and ignore the map.

Instead, each active third-person update calculates:

```text
Player Eye Position
        ↓
Desired Camera Position
        ↓
TraceLine
        ↓
Collision?
   ↙          ↘
 YES           NO
  ↓             ↓
Trace End      Desired
Position       Position
  ↓
Apply Padding
  ↓
Resolved Camera Position
```

The trace is performed between the player's eye position and the desired camera location.

When an obstacle is detected, the camera is moved toward the trace hit point and a configurable safety padding is applied.

---

## 🧩 TraceLine-Based Resolution

The implementation uses:

```pawn
EngFunc_TraceLine
```

and resolves the final camera position using the trace fraction and trace end position.

The wall protection is therefore **TraceLine based**.

> This should not be confused with a full volumetric swept-hull camera collision system. The current implementation performs a line-based geometry check.

This distinction is documented intentionally so server administrators know exactly what the plugin does.

---

# 👤 Per-Player Camera State

Camera state is stored individually for every player.

Each player maintains:

```text
Third Person Mode
Camera Entity
```

independently.

For example:

```text
Player 1 → Mode 1
Player 2 → Mode 0
Player 3 → Mode 3
Player 4 → Mode 2
```

Changing one player's camera does not change another player's camera state.

---

# 🔄 Player Lifecycle Management

The plugin actively manages camera entities during player lifecycle events.

## Player Connect

A new player starts with:

```text
Mode = 0
Camera Entity = none
```

A short welcome/help message is then printed to the player's console/chat.

---

## Player Spawn

If a player already has a third-person mode selected:

```text
Mode > 0
```

the plugin schedules a camera recreation after spawn.

This prevents the camera state from being permanently lost when the player respawns.

---

## Player Death

When the player dies:

```text
Camera Entity → removed
```

The normal player view is restored.

---

## Player Disconnect

When a player disconnects:

```text
Camera Entity → removed
Camera State  → reset
```

This prevents stale camera entities from remaining associated with a disconnected player.

---

# 🎮 Commands

## Main Camera Cycle Command

```text
xai_thirdperson
```

Every execution advances the camera state:

```text
0 → 1 → 2 → 3 → 0
```

---

## XAI Command Aliases

The plugin also supports:

```text
xai tp
```

and:

```text
xai thirdperson
```

These execute the same camera cycle functionality.

---

## Direct Mode Selection

Use:

```text
xai_tp_mode <0-3>
```

Examples:

```text
xai_tp_mode 0
```

```text
xai_tp_mode 1
```

```text
xai_tp_mode 2
```

```text
xai_tp_mode 3
```

### Invalid Values

Values outside the supported range are normalized to:

```text
0
```

Therefore:

```text
xai_tp_mode 4
```

does not create a fifth camera mode.

---

# 💬 Chat Commands

The plugin recognizes:

```text
/tp
```

```text
!tp
```

```text
/thirdperson
```

Team chat also supports:

```text
/tp
```

These commands cycle the camera mode.

---

# ⌨️ Recommended F1 Bind

The recommended client-side bind is:

```text
bind F1 xai_thirdperson
```

This gives the player a convenient one-key camera switch.

### Important

The plugin does **not** force this bind.

The player chooses whether to add the bind to the client.

No automatic:

```text
config.cfg
```

modification is performed.

---

# ⚙️ CVAR Reference

The plugin exposes seven configurable CVARs.

| CVAR | Default | Runtime Range | Purpose |
| :--- | ---: | :---: | :--- |
| `xai_tp_close_distance` | `88.0` | `40.0 - 320.0` | Mode 1 camera distance |
| `xai_tp_close_height` | `24.0` | `-24.0 - 96.0` | Mode 1 camera height |
| `xai_tp_far_distance` | `176.0` | `40.0 - 320.0` | Mode 2 camera distance |
| `xai_tp_far_height` | `36.0` | `-24.0 - 96.0` | Mode 2 camera height |
| `xai_tp_rear_distance` | `88.0` | `40.0 - 320.0` | Mode 3 camera distance |
| `xai_tp_rear_height` | `24.0` | `-24.0 - 96.0` | Mode 3 camera height |
| `xai_tp_padding` | `12.0` | `2.0 - 32.0` | Wall collision padding |

---

# 📐 Runtime Value Protection

Camera values are clamped during runtime.

## Distance

```text
Minimum = 40.0
Maximum = 320.0
```

Therefore:

```text
distance < 40.0
```

becomes:

```text
40.0
```

and:

```text
distance > 320.0
```

becomes:

```text
320.0
```

---

## Height

```text
Minimum = -24.0
Maximum = 96.0
```

---

## Wall Padding

```text
Minimum = 2.0
Maximum = 32.0
```

This prevents unreasonable CVAR values from being used directly in the camera collision correction.

---

# 🛠️ Example Server Configuration

Create or edit:

```text
addons/XAI-EKLENTISI/ozellikler/thirdperson.cfg
```

Example:

```cfg
// XAI Advanced Third Person Camera
// Plugin Version: 2.2.1

xai_tp_close_distance "88.0"
xai_tp_close_height "24.0"

xai_tp_far_distance "176.0"
xai_tp_far_height "36.0"

xai_tp_rear_distance "88.0"
xai_tp_rear_height "24.0"

xai_tp_padding "12.0"
```

You can also configure the CVARs from:

```text
server.cfg
```

---

# 📁 Automatic Configuration Loading

During plugin initialization the following configuration path is executed:

```text
addons/XAI-EKLENTISI/ozellikler/thirdperson.cfg
```

This allows the camera configuration to remain separate from the main server configuration when desired.

---

# 🧩 XAI Main Menu Integration

The plugin can integrate with:

```text
xai_main_menu
```

When that library/plugin is detected, the third-person feature registers itself with the main XAI menu.

The registered menu item is:

```text
Third Person Kamera [F1 / 3 Mod]
```

and uses:

```text
xai_thirdperson
```

as its command.

---

## 🔌 Optional Dependency

The main menu integration is optional.

### With `xai_main_menu`

```text
XAI Main Menu
      ↓
Third Person Kamera
      ↓
xai_thirdperson
      ↓
Camera Cycle
```

### Without `xai_main_menu`

```text
Player
  ↓
xai_thirdperson
  ↓
Camera Cycle
```

The third-person camera plugin continues to work independently.

---

# 🏗️ Camera Entity Architecture

For every active third-person player, the plugin creates an `info_target` entity.

The runtime entity uses:

```text
classname = xai_tp_cam
```

and is configured as:

```text
MOVETYPE_NONE
SOLID_NOT
owner = player
```

The camera entity is hidden using:

```text
EF_NODRAW
```

and the player's view is attached to the entity with:

```pawn
attach_view(player, camera)
```

---

# 🎞️ Real-Time Camera Update

When third-person mode is active, the plugin updates the camera during:

```text
client_PreThink
```

The camera calculation uses:

```text
Player Origin
View Offset
View Angle
Forward Vector
Camera Distance
Camera Height
Collision Trace
Padding
```

The resulting position and angles are then applied to the camera entity.

---

# 🧭 Camera Calculation Flow

The simplified runtime flow is:

```text
client_PreThink
       ↓
Check player alive
       ↓
Check active camera mode
       ↓
Read player origin
       ↓
Read player view offset
       ↓
Calculate eye position
       ↓
Calculate direction vectors
       ↓
Select camera mode
       ↓
Read CVAR distance/height
       ↓
Clamp runtime values
       ↓
Calculate desired camera position
       ↓
TraceLine
       ↓
Resolve collision
       ↓
Move camera entity
       ↓
Update camera angles
       ↓
attach_view()
```

---

# 🛡️ Client-Side Policy

This plugin is designed to avoid forced client configuration changes.

It does not automatically write a player bind such as:

```text
bind F1 xai_thirdperson
```

to the player's:

```text
config.cfg
```

The F1 bind is only provided as a recommended manual configuration.

---

# 📦 External Assets

The camera system itself does not require:

```text
custom camera model
custom camera sprite
custom camera sound
```

The camera is created dynamically using a GoldSrc entity at runtime.

The camera entity can inherit the player's current model internally, but the entity is rendered hidden using:

```text
EF_NODRAW
```

so a separate camera asset package is not required.

---

# ✅ Installation — Precompiled AMXX

The repository contains a precompiled:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

### Step 1

Copy:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

to:

```text
addons/amxmodx/plugins/
```

### Step 2

Open:

```text
addons/amxmodx/configs/plugins.ini
```

Add:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

### Step 3

Optional configuration:

```text
addons/XAI-EKLENTISI/ozellikler/thirdperson.cfg
```

### Step 4

Restart the server or change the map.

### Step 5

Test:

```text
xai_thirdperson
```

or:

```text
/tp
```

---

# 🧰 Installation — Source Compilation

The repository also contains the Pawn source:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.sma
```

The source currently includes:

```pawn
#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <xs>
```

The plugin therefore expects the corresponding AMX Mod X development environment and include files.

---

# 🔧 Runtime Dependencies

## Required

```text
AMX Mod X
engine
fakemeta
```

## Optional

```text
xai_main_menu
```

`xai_main_menu` is required only for automatic main-menu registration.

The camera itself can operate standalone.

---

# 📂 Repository Structure

Current repository structure:

```text
GoldSrc-Advanced-Thirdperson/
│
├── LICENSE
├── README.md
│
├── XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
└── XAI-GoldSrc-Advanced-Thirdperson-Plugin.sma
```

---

# 🧪 Basic Test Checklist

After installation, test the following:

### Camera cycle

```text
xai_thirdperson
```

Expected sequence:

```text
0 → 1 → 2 → 3 → 0
```

### Direct modes

```text
xai_tp_mode 0
xai_tp_mode 1
xai_tp_mode 2
xai_tp_mode 3
```

### Chat

```text
/tp
!tp
/thirdperson
```

### XAI aliases

```text
xai tp
xai thirdperson
```

### F1

```text
bind F1 xai_thirdperson
```

### Wall testing

Test the camera near:

```text
walls
corners
narrow corridors
small rooms
map obstacles
```

### Lifecycle testing

Test:

```text
connect
spawn
third-person activation
death
respawn
disconnect
```

---

# 🐛 Troubleshooting

## `xai_thirdperson` does nothing

Check:

```text
addons/amxmodx/configs/plugins.ini
```

and verify:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

is present.

Then restart/change the map.

---

## `/tp` does nothing

Verify the plugin is loaded.

Then test the direct console command:

```text
xai_thirdperson
```

If the console command works while chat does not, check the exact chat command syntax:

```text
/tp
!tp
/thirdperson
```

---

## Camera disappears after death

This is expected behavior.

The plugin removes the camera entity when the player dies.

After respawn, the selected third-person mode is reapplied when appropriate.

---

## Camera is too close to a wall

Increase:

```text
xai_tp_padding
```

Example:

```cfg
xai_tp_padding "16.0"
```

The runtime-supported padding range is:

```text
2.0 - 32.0
```

---

## Camera is too far away

Reduce:

```text
xai_tp_close_distance
```

or:

```text
xai_tp_far_distance
```

depending on the active mode.

Remember that runtime distance is bounded to:

```text
40.0 - 320.0
```

---

## `xai_main_menu` is not showing the camera option

The third-person plugin is designed to work without the main menu.

Check that:

```text
xai_main_menu
```

is actually loaded.

If it is unavailable, use:

```text
xai_thirdperson
```

directly.

---

# ❓ Frequently Asked Questions

## Does this plugin work without the XAI main menu?

**Yes.**

The main menu integration is optional.

---

## Does this plugin automatically bind F1?

**No.**

Use:

```text
bind F1 xai_thirdperson
```

manually if desired.

---

## Does the plugin modify the player's config.cfg?

**No forced client configuration modification is part of the implementation.**

---

## Are custom camera models required?

**No.**

The camera is created dynamically.

---

## Can every player use a different mode?

**Yes.**

The plugin stores camera state per player.

---

## Is Mode 0 a real camera mode?

Mode `0` represents the normal first-person state / custom camera disabled state.

---

## Can I set a camera mode directly?

Yes:

```text
xai_tp_mode 0
xai_tp_mode 1
xai_tp_mode 2
xai_tp_mode 3
```

---

## Can distance and height be changed while the server is running?

Yes.

The plugin reads its camera CVAR values during runtime.

---

## Does the wall system use TraceLine?

Yes.

The current implementation uses a GoldSrc `TraceLine` call between the player eye position and the desired camera position.

---

# 🔍 Search & Discoverability

This project is intentionally documented around the terminology commonly used when searching for GoldSrc and Counter-Strike 1.6 plugins.

Relevant project terms include:

```text
GoldSrc
GoldSrc plugin
Counter-Strike 1.6
CS 1.6
CS16
Counter Strike 1.6 plugin
AMX Mod X
AMXX
AMXX plugin
AMX plugin
Pawn plugin
Pawn scripting
third person
thirdperson
third person camera
thirdperson camera
camera plugin
camera system
GoldSrc camera
CS 1.6 third person
CS16 third person
CS 1.6 camera plugin
AMXX third person
AMX Mod X third person
multiplayer third person camera
GoldSrc third person camera
```

These terms are used as descriptive project terminology rather than as unrelated keyword stuffing.

---

# 🧠 Technical Philosophy

XAI Advanced Third Person Camera is intentionally kept as a focused plugin.

The plugin owns:

```text
Camera State
Camera Entity
Camera Modes
Camera CVARs
Camera Commands
Camera Collision Resolution
Camera Lifecycle
Main Menu Registration
```

It does not require the entire XAI framework to function.

This makes it suitable for:

```text
Standalone GoldSrc servers
CS 1.6 servers
XAI-based servers
Modular AMX Mod X installations
Custom gameplay frameworks
```

---

# 🔌 Modular Design

The plugin is designed so that the camera feature can be deployed independently.

Architecture:

```text
                    ┌──────────────────┐
                    │   XAI Main Menu  │
                    │    (Optional)    │
                    └────────┬─────────┘
                             │
                             │ register
                             ▼
                  ┌──────────────────────┐
                  │ XAI Third Person     │
                  │ Camera Plugin        │
                  └──────────┬───────────┘
                             │
             ┌───────────────┼────────────────┐
             │               │                │
             ▼               ▼                ▼
       Camera Modes      CVAR System      Commands
             │               │                │
             └───────────────┼────────────────┘
                             ▼
                    Runtime Camera Entity
                             │
                             ▼
                       GoldSrc View
```

---

# 📝 Source Code

Source:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.sma
```

Compiled plugin:

```text
XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx
```

---

# 📌 Plugin Metadata

```text
Plugin Name : XAI Advanced 3-Mode Third Person
Version     : 2.2.1
Author      : @xansuz
Engine      : GoldSrc
Language    : Pawn
Framework   : AMX Mod X / AMXX
Camera Modes: 0, 1, 2, 3
License     : MIT
```

---

# 📜 License

This project is released under the:

```text
MIT License
```

Copyright:

```text
Copyright (c) 2026 xansuz
```

See the complete license:

```text
LICENSE
```

---

# 👤 Author

Developed by:

**[@xansuz](https://github.com/xansuz)**

GitHub:

https://github.com/xansuz

Project:

https://github.com/xansuz/GoldSrc-Advanced-Thirdperson

---

# ⭐ Support the Project

If this plugin is useful for your GoldSrc / CS 1.6 server:

⭐ Star the repository  
🐛 Report reproducible bugs  
💡 Suggest technically relevant improvements  
🔧 Contribute improvements  
📖 Improve documentation

---

# 🔗 Project Links

| Resource | Link |
| :--- | :--- |
| GitHub Repository | https://github.com/xansuz/GoldSrc-Advanced-Thirdperson |
| Source Code | `XAI-GoldSrc-Advanced-Thirdperson-Plugin.sma` |
| Compiled Plugin | `XAI-GoldSrc-Advanced-Thirdperson-Plugin.amxx` |
| License | `LICENSE` |
| AMX Mod X | https://www.amxmodx.org/ |
| Developer | https://github.com/xansuz |

---

# 🚦 Current Release

```text
XAI Advanced Third Person Camera
Version 2.2.1
```

Current implementation includes:

```text
✓ 3 third-person perspectives
✓ First-person fallback
✓ Per-player mode state
✓ Runtime camera entity
✓ TraceLine collision resolution
✓ Configurable camera distance
✓ Configurable camera height
✓ Configurable wall padding
✓ Chat commands
✓ Console commands
✓ Direct mode selection
✓ XAI command aliases
✓ Optional xai_main_menu registration
✓ Spawn recovery
✓ Death cleanup
✓ Disconnect cleanup
✓ Client-friendly operation
```

---

# 🎯 Project Scope

This repository focuses specifically on the:

> **GoldSrc / Counter-Strike 1.6 / AMX Mod X Third Person Camera**

It is not intended to replace:

```text
server administration systems
bot AI systems
gameplay frameworks
economy systems
player management systems
complete XAI server cores
```

Instead, it provides a focused and reusable camera component that can be integrated into a larger XAI or AMXX server architecture.

---

<p align="center">

### 🎥 XAI Advanced Third Person Camera

**GoldSrc • CS 1.6 • AMX Mod X • AMXX • Pawn • Third Person • Camera**

Developed by **[@xansuz](https://github.com/xansuz)**

</p>

