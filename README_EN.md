# KegelTimer

**Kegel Exercise Timer for macOS · Timed Reminders · Privacy First**

[中文](README.md) | [日本語](README_JP.md)

![KegelTimer Screenshot](assets/screenshot.png)

## Introduction

KegelTimer is a minimal macOS menu bar app that helps you build a habit of doing Kegel exercises on schedule.

- ⏰ **Countdown Reminder**: Set interval time, automatic popup reminder
- 🌻 **Flower Animation**: Blooms during contraction, closes during relaxation
- 📊 **Progress Tracking**: Segmented progress bar shows training progress
- 🔒 **Privacy First**: No accounts, no data collection, fully local

---

## Quick Start

### 1. Download & Install

```bash
# Download from GitHub Releases
https://github.com/marswaveai/KegelTimer/releases/latest
```

Download `KegelTimer.app.zip` → Unzip → Drag to `/Applications` folder

### 2. First Use

1. Open KegelTimer (🍑 icon appears in menu bar)
2. Click icon → **Settings...** → Adjust reminder interval (default: 60 minutes)
3. Wait for countdown to end, or manually click **Start Training**

### 3. Training Flow

```
Countdown ends → Card pops up + beep → 
Follow flower animation (contract → relax) → 
Complete all sets → Click × to close → Countdown restarts
```

---

## Features

### Main Interface

| State | Display | Action |
|-------|---------|--------|
| Idle | Next reminder in: X min | Click card to start |
| Training | Flower animation + Progress bar | Click card to pause/resume |
| Complete | ✅ Session Complete! | Auto-close or click × |

### Flower Animation

- **Bloom** (Contract): Hold for X seconds (configurable 1-10 sec)
- **Close** (Relax): Hold for X seconds (configurable 1-10 sec)

### Progress Bar

- Each segment represents one repetition
- Green = Completed, Gray = Remaining
- Bottom shows current set/total sets

---

## Settings

Open **Settings...** (shortcut `⌘,`) to adjust:

| Option | Range | Default | Description |
|--------|-------|---------|-------------|
| **Remind Every** | 5-240 min | 60 min | How often to remind |
| **Contraction** | 1-10 sec | 5 sec | Hold duration for contraction |
| **Relaxation** | 1-10 sec | 5 sec | Rest duration between reps |
| **Repetitions** | 1-30 reps | 10 reps | Reps per set |
| **Sets** | 1-10 sets | 3 sets | Sets per session |
| **Rest Between Sets** | 10-180 sec | 60 sec | Break between sets |

### Example Configurations

**Beginner Mode** (~3 minutes):
- Contract 3 sec, Relax 3 sec
- 5 reps per set, 2 sets
- 30 sec rest between sets

**Advanced Mode** (~10 minutes):
- Contract 10 sec, Relax 5 sec
- 15 reps per set, 5 sets
- 60 sec rest between sets

---

## FAQ

### Q: What are Kegel exercises?

A: Kegel exercises strengthen the pelvic floor muscles, which support the bladder, bowel, and uterus. Consult a healthcare provider before starting any exercise routine.

### Q: How do I dismiss the reminder?

A: Click the × button in the top-right corner of the card to close and reset the countdown. You can also click the menu bar icon → Stop Training.

### Q: Does it collect my data?

A: **No**. All data is stored locally in UserDefaults and never uploaded to any server.

### Q: Is Apple Silicon supported?

A: Yes. Built with native Swift, supports both Intel and Apple Silicon Macs.

### Q: Minimum system requirements?

A: macOS 14.0 (Sonoma) or later.

---

## Tech Stack

- **Language**: Swift 6.2
- **Frameworks**: SwiftUI + AppKit
- **Architecture**: Single-file app (~900 lines)
- **Updates**: GitHub Releases auto-update

---

## Build Instructions

```bash
git clone https://github.com/marswaveai/KegelTimer.git
cd KegelTimer

# Generate icon (optional, pre-generated icon included)
./scripts/generate_icon.sh

# Build app
./scripts/build_app.sh

# Output location
dist/KegelTimer.app
```

---

## Changelog

### v1.0.0
- ✨ Initial release
- ⏰ Countdown reminder feature
- 🌻 Flower animation effect
- 📊 Segmented progress bar
- 🔄 Auto-update mechanism

---

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=marswaveai/KegelTimer&type=Date)](https://star-history.com/#marswaveai/KegelTimer&Date)

---

## License

GNU General Public License v3.0

---

## Links

- [GitHub Repository](https://github.com/marswaveai/KegelTimer)
- [Issue Tracker](https://github.com/marswaveai/KegelTimer/issues)
- [Official Website](https://kegeltimer.com)
