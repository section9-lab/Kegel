# KegelTimer

**macOS Kegel Exercise Timer · Smart Reminders · Privacy First**

[中文](README.md) | [日本語](README_JP.md)

![KegelTimer Screenshot](assets/KegelTimer.png)

## Introduction

KegelTimer is a minimalist macOS menu bar application designed to help you build a habit of regular Kegel exercises.

- ⏰ **Smart Reminders**: Customizable intervals with automatic pop-ups.
- 🌻 **Dynamic Interaction**: Follow the blooming flower animation for contraction and relaxation.
- 📊 **Smooth Progress**: New segmented progress bar for real-time tracking of your session.
- 🚀 **Instant Start**: Click and start immediately—no unnecessary delays.
- 🔒 **Privacy First**: No account required, no data collection, 100% local operation.
- 💻 **Native Support**: Fully optimized for Apple Silicon (M1/M2/M3).

---

## Quick Start

### 1. Installation

Go to [GitHub Releases](https://github.com/section9-lab/Kegel/releases/latest) and download the latest `KegelTimer-AppleSilicon.zip`. Unzip it and drag `KegelTimer.app` into your `/Applications` folder.

### 2. Basic Operation

1. **Enable Reminders**: Launch the app, and the 🌼 icon will appear in your menu bar.
2. **Custom Settings**: Click the icon → **Settings...** (⌘,) to adjust intervals, durations, and repetitions.
3. **Start Training**: Wait for the reminder to pop up, or click **Start/Pause** in the menu bar at any time.

---

## Feature Highlights

### Interactive Overlay

- **Smart Hover**: The close button reveals itself only when your mouse is nearby, keeping the UI clean.
- **Real-time Countdown**: Displays remaining seconds for the current phase directly in the overlay.
- **Status Badge**: Elegant "Next reminder" capsule tag with smooth animations.

### Evolved Progress Bar

- **Phase Splitting**: Each repetition is split equally between contraction and relaxation phases.
- **Consistent Growth**: The bar fills smoothly from left to right for both phases, providing an intuitive experience.

---

## Settings Explained

| Option | Range | Description |
|------|------|------|
| **Interval** | 5-240 min | Time between training sessions |
| **Contract** | 1-15 sec | Duration to hold each muscle contraction |
| **Relax** | 1-15 sec | Rest time after each contraction |
| **Reps** | 5-50 reps | Number of repetitions per session |

---

## FAQ

### Q: Does it support Intel processors?
A: Current releases are optimized for Apple Silicon (M-series). Intel users can compile the app from source.

### Q: Why does training start immediately?
A: To improve efficiency, we removed the preparation countdown. Please be ready when you start.

### Q: How is my data handled?
A: The app runs completely locally. All configurations are stored in system `UserDefaults`. No data is ever uploaded.

---

## Technical Specifications

- **Language**: Swift 6.0
- **Framework**: SwiftUI + AppKit
- **Architecture**: Reactive State Management (Combine + @MainActor)
- **Deployment**: Automated Pipeline via GitHub Actions

---

## Developer Guide

To build or contribute to the project:

```bash
git clone https://github.com/section9-lab/Kegel.git
cd Kegel

# Build and package locally
bash scripts/package.sh

# Output location
dist/KegelTimer.app
```

---

## Changelog

### v1.0.0
- ✨ **Workflow Overhaul**: Removed prep countdown for instant training.
- 🎨 **UI Upgrade**: New overlay design with hover interactions and optimized corners.
- 📊 **Progress Logic**: Redesigned progress bar with phase splitting and left-to-right filling.
- ⚙️ **Stability**: Fixed timer concurrency issues and improved state safety.
- 🤖 **CI/CD**: Integrated GitHub Actions for automated Apple Silicon builds.

---

## License

This project is licensed under [GNU General Public License v3.0](LICENSE).

---

## Community & Feedback

- [Submit an Issue](https://github.com/section9-lab/Kegel/issues)
- [Repository](https://github.com/section9-lab/Kegel)
