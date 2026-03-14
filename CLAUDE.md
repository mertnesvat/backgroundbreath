# CLAUDE.md — BackgroundBreath

## Project Overview

BackgroundBreath is a macOS menu-bar breathing companion app. It displays a transparent, animated triangle overlay on the user's desktop that visualizes breathing phases (inhale, hold, exhale). The app is lightweight (~700 lines of Swift), has zero external dependencies, and runs as a menu-bar-only app (no Dock icon).

## Build & Run

```bash
# Generate Xcode project (required after changing project.yml)
xcodegen generate

# Build
xcodebuild -scheme BackgroundBreath -destination 'platform=macOS' build

# Run tests
xcodebuild -scheme BackgroundBreath -destination 'platform=macOS' test

# Build release
xcodebuild -scheme BackgroundBreath -configuration Release -destination 'platform=macOS' build
```

**Prerequisites**: Xcode 15+, XcodeGen (`brew install xcodegen`), macOS 13+

## Architecture

This is a simple, flat architecture — no MVVM, no protocols, no dependency injection. Views directly observe `ObservableObject` models via `@ObservedObject`.

### Core Types

| Type | Role |
|------|------|
| `AppDelegate` | App lifecycle, menu bar, floating panel management, Combine subscribers |
| `FloatingPanel` | Custom `NSPanel` subclass — transparent, borderless, always-on-top, joins all Spaces |
| `BreathTimer` | Phase cycling engine. Publishes `phase`, `currentPhaseDuration`, `phaseStartDate`. Computed `phaseProgress` (0→1) for continuous animation. |
| `BreathPattern` | Static definitions of 6 breathing patterns with phase sequences |
| `BreathSettings` | `@Published` properties persisted via `UserDefaults` `didSet` pattern |
| `BreathStyle` | Enum: `.path`, `.summit`, `.prism` |

### View Layer

| View | Role |
|------|------|
| `TriangleBreathView` | Parent view. Wraps content in `TimelineView(.animation)` when running, switches between styles. Shows static snapshot when paused. |
| `TrianglePathStyle` | Concept C — draws/erases triangle edges using `Canvas` + `trimmedPath`. Only ~1/3 visible at any moment. |
| `TriangleSummitStyle` | Concept A — permanent ghost frame + traveling dot with trail, using `Canvas`. |
| `TrianglePrismStyle` | Concept B — solid translucent triangle with rotation/scale animation via SwiftUI `.animation`. |
| `TriangleShape` | Shared `Shape` conformance. Path: bottom-left → apex → bottom-right → close. |
| `SettingsView` | macOS Form with `.formStyle(.grouped)`. Live preview, style picker, display controls, color sliders. |
| `AboutView` | Static about screen with version and credits. |

### Key Patterns

**Animation system**: `TimelineView(.animation)` in the parent view drives 60fps re-evaluation. Each frame, `timer.phaseProgress` is computed from `Date().timeIntervalSince(phaseStartDate) / currentPhaseDuration`. This is pull-based — zero cost when paused.

**Settings persistence**: Every `@Published` property in `BreathSettings` has a `didSet` that writes to `UserDefaults.standard`. The `init()` reads with fallback defaults. To add a new setting, follow this exact pattern.

**Panel sizing**: `AppDelegate` subscribes to `settings.$orbSize` via Combine and calls `panel.setContentSize(NSSize(width: size + 28, height: size + 40))`. The `+28/+40` provides padding around the triangle.

**Triangle path winding**: The triangle path starts at bottom-left, goes to apex, then bottom-right, then closes. This means `trim(0, 0.33)` draws the left edge (inhale), `trim(0.33, 0.66)` draws the right edge (exhale), `trim(0.66, 1.0)` draws the base (hold).

## File Map

```
BackgroundBreath/
├── Assets.xcassets/            # App icon (triangle logo)
├── AppDelegate.swift           # Menu bar, panel setup, Combine subscribers
├── FloatingPanel.swift         # Custom NSPanel configuration
├── BreathTimer.swift           # Phase state machine + progress
├── BreathPattern.swift         # 6 predefined breathing patterns
├── BreathSettings.swift        # UserDefaults-backed @Published settings
├── BreathStyle.swift           # Style enum (path/summit/prism)
├── TrianglePath.swift          # TriangleShape + BreathPhase.triangleSegment
├── TriangleBreathView.swift    # Three style implementations + parent view
├── BreathAnimationView.swift   # Legacy circle orb (unused, kept as reference)
├── BreathOverlayApp.swift      # @main entry point
├── SettingsView.swift          # Settings form + AboutView
└── Info.plist                  # LSUIElement=true (menu bar only)

BackgroundBreathTests/
├── BreathStyleTests.swift      # Enum cases, rawValues, defaults
├── TriangleSegmentTests.swift  # Phase→edge mapping, contiguity, coverage
├── BreathTimerTests.swift      # Progress, lifecycle, phaseStartDate
└── BreathSettingsTests.swift   # Persistence, migration, defaults
```

## Conventions

- **No external dependencies.** This app ships as pure Swift + SwiftUI + AppKit.
- **No protocols or abstractions.** Concrete types throughout. Don't add protocols unless there's a concrete second implementation.
- **Canvas over Shape+trim for complex drawing.** Path and Summit styles use `Canvas` for multi-layer drawing. Prism uses declarative SwiftUI modifiers since it doesn't need continuous progress.
- **System fonts only.** Uses `.system(..., design: .rounded)` for labels. No custom font files.
- **HSB color model.** All colors stored as hue values (0–1). Saturation and brightness are computed in the view layer.
- **Keep it small.** This is a utility app. Resist the urge to add frameworks, abstractions, or complexity.

## Adding a New Breathing Style

1. Add a case to `BreathStyle` enum in `BreathStyle.swift` with `displayName` and `subtitle`
2. Create a new style struct in `TriangleBreathView.swift` (follow `TrianglePathStyle` as a template)
3. Add the case to the `switch` in `TriangleBreathView.body` (both running and paused branches)
4. Add a style icon in `SettingsView.styleIcon(for:)`
5. Add a preview case in `SettingsView.previewTriangle(size:date:)`
6. Tests will catch missing cases in the enum

## Adding a New Setting

1. Add `@Published var name: Type { didSet { UserDefaults.standard.set(name, forKey: "name") } }` to `BreathSettings`
2. Add initialization in `init()`: `name = UserDefaults.standard.object(forKey: "name") as? Type ?? default`
3. Add UI control in `SettingsView`
4. If the setting affects the panel, add a Combine subscriber in `AppDelegate.applicationDidFinishLaunching`

## Design Direction

See `DesignDirection.md` for the full design spec, including:
- Why triangles instead of circles
- The three concepts and their rationale
- Color palette decisions
- Animation philosophy
- Ambient UI constraints

## Known Quirks

- `BreathAnimationView.swift` is the old circle orb — kept as reference but not used. Can be deleted.
- The `date` parameter in Path/Summit style views is never read directly — it exists to trigger SwiftUI redraws from `TimelineView`. Don't remove it.
- `holdAfterInhale` has a zero-width triangle segment (`start == end`). Both Path and Summit styles handle this with `phase == .holdAfterInhale` checks.
