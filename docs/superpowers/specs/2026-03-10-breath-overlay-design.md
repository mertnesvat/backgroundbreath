# BackgroundBreath — Breath Overlay Design

**Date:** 2026-03-10
**Status:** Approved
**Version:** 1.0

## Overview

A minimal macOS menu bar app that displays a floating, always-on-top breathing guide. A warm amber/orange glowing orb pulses slowly (5.5s inhale / 5.5s exhale) with "inhale"/"exhale" text below it, sitting in the user's peripheral vision while they work.

## Design Goals

- **Ambient, not intrusive:** Nearly transparent (~15% opacity), sits in peripheral vision
- **Click-through:** User can click through the orb to interact with apps behind it
- **Freely draggable:** User can reposition the window anywhere
- **No dock icon:** Pure menu bar app (`LSUIElement = true`)
- **Zero interaction required:** Just ambient pacing, auto-starts on launch

## Visual Design

- **Orb size:** ~60pt circle
- **Gradient:** Warm amber/orange radial gradient
  - Core: `rgba(255, 199, 99, 1.0)` — warm amber
  - Mid: `rgba(255, 130, 61, 0.5)` — orange fade
  - Edge: `.clear`
- **Glow:** Double shadow for bloom effect
  - Inner: amber at 60% opacity, radius 16
  - Outer: orange at 25% opacity, radius 40
- **Text:** "inhale" / "exhale", 9pt rounded, 1.5 letter-spacing, 70% opacity
- **Window opacity:** 15% (`alphaValue = 0.15`)

## Animation

- **Rhythm:** 5.5s inhale / 5.5s exhale (equal ratio)
- **Scale:** Inhale → 1.0x, Exhale → 0.6x
- **Easing:** `.easeInOut(duration: 5.5)` on scale, `.easeInOut(duration: 0.6)` on text

## Architecture

- `@NSApplicationDelegateAdaptor` bridges SwiftUI App lifecycle with AppKit delegate
- `LSUIElement = true` in Info.plist suppresses dock icon
- `NSPanel` with `.floating` level, `.borderless` style, transparent background
- `isMovableByWindowBackground = true` for drag-anywhere behavior
- `collectionBehavior = [.canJoinAllSpaces, .stationary]` for all-spaces visibility

## Menu Bar Actions (V1)

1. **Pause / Start** — toggle animation
2. *(separator)*
3. **Quit** — terminate app

## File Structure

```
BackgroundBreath/
├── BackgroundBreath.xcodeproj
├── BackgroundBreath/
│   ├── BreathOverlayApp.swift      # @main, @NSApplicationDelegateAdaptor
│   ├── AppDelegate.swift           # NSStatusItem + FloatingPanel lifecycle
│   ├── FloatingPanel.swift         # NSPanel subclass
│   ├── BreathTimer.swift           # ObservableObject, phase toggle
│   ├── BreathAnimationView.swift   # SwiftUI orb + label
│   └── Info.plist                  # LSUIElement = true
└── docs/
    └── superpowers/specs/
        └── 2026-03-10-breath-overlay-design.md
```

## Future (not in V1)

- Configurable rhythms (4-7-8, box breathing)
- Settings panel (size, opacity, rhythm)
- Body scan audio whispers
- HRV sync for adaptive rhythm
