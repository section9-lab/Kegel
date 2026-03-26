# AGENTS.md

This file provides guidance to Qoder (qoder.com) when working with code in this repository.

## Project Overview

Kegel is a free, open-source Kegel exercise timer for macOS. It's a menu bar application that guides users through pelvic floor training sessions with visual cues for contraction, relaxation, and rest phases.

## Build & Development Commands

### Build the app (release mode)
```bash
swift build -c release
```

### Generate app icon (required before building)
```bash
./scripts/generate_icon.sh
```

### Build complete .app bundle
```bash
./scripts/build_app.sh
```
Output: `dist/Kegel.app`

### Run during development
```bash
.build/release/Kegel
```

## Architecture

- **Single-file Swift application**: All logic is in `Sources/Kegel/main.swift` (~950 lines)
- **Swift Package Manager**: Defined in `Package.swift`
- **Platform**: macOS 14.0+
- **UI Framework**: SwiftUI + AppKit hybrid

### Key Components (in main.swift)

1. **TrainingConfig** - User-configurable training parameters (contraction/relax duration, reps, sets)
2. **TrainingPhase** - State machine for training states (idle, ready, contracting, relaxing, resting, completed, paused)
3. **AppState** - Central state management with timer logic
4. **StatusItemController** - Menu bar UI and interactions, update checker
5. **OverlayPanelController** - Floating overlay window showing current phase
6. **SettingsWindow** - SwiftUI-based settings panel for customization
7. **UpdateService** - GitHub Releases-based self-update mechanism

### Training Flow

```
idle → readyToStart → (contract → relax) × reps → resting → repeat sets → completed
```

### Self-Update Mechanism

The app checks for updates on launch and via menu bar "Check for Updates..." item:
- Fetches latest release from GitHub API (`marswaveai/KegelTimer`)
- Downloads `Kegel.app.zip` asset
- Replaces current app bundle and relaunches
- Requires the zip file to be named `Kegel.app.zip` in releases

### File Structure

```
Kegel/
├── Sources/Kegel/main.swift    # All application logic
├── App/
│   ├── Info.plist               # Bundle configuration
│   ├── Kegel.entitlements       # Sandbox entitlements (empty)
│   └── Kegel.iconset/           # Icon assets
├── scripts/
│   ├── generate_icon.sh         # Generate app icon
│   └── build_app.sh             # Full build pipeline
├── dist/                        # Build output (Kegel.app)
└── Package.swift
```

## Important Notes

- The app uses `LSUIElement: true` — it runs as a menu bar agent without a dock icon
- No external dependencies required
- Code signing is optional for development; ad-hoc signing works fine
- Settings are persisted in UserDefaults under `com.kegel.trainingConfig`
