# BackgroundBreath — Design Direction

## Context & Constraints

BackgroundBreath is a **macOS menu-bar breathing companion** that floats as a transparent overlay on the user's desktop. It must:

- Sit on-screen permanently without demanding attention
- Allow the user to see and interact with content behind it (click-through, opacity control)
- Work at low opacity (30-50%) without becoming invisible
- Remain visually clear at small sizes (60-120pt)
- Convey breathing phase (inhale, hold, exhale) through shape/motion, not just color
- Feel like a **designed object** — not a generic AI wellness orb

## Design Principles

1. **Stroke over fill.** Thin lines are ambient; solid fills block content.
2. **Position is information.** Where a light sits on the triangle tells you the phase — no color legend needed.
3. **Ephemeral over permanent.** The shape should feel alive, not static.
4. **Quiet confidence.** The design earns attention through precision, not brightness.

## Current Problems

- Generic glowing circle is indistinguishable from any AI breathing app
- Binary scale animation (1.0 → 0.6) feels mechanical, not organic
- Default cyan/magenta/orange palette is the "AI color palette"
- Dual-shadow glow system obscures content behind the orb
- No visual narrative — the circle just pulses, it doesn't tell a story

---

## Selected Direction: Triangle as Journey

The breathing indicator is a **triangle drawn as a continuous path**. Breath phases map to positions on the triangle's edges:

```
        /\          APEX = full inhale / hold
       /  \
      /    \        LEFT EDGE  = inhale (ascending)
     /      \       RIGHT EDGE = exhale (descending)
    /________\      BASE       = hold after exhale / rest
```

This creates a **spatial narrative**: inhale climbs, exhale descends, hold rests. The user always knows where they are in the breath cycle by where the activity is on the triangle.

---

## Concept A: "The Summit" — Tracing Light (Recommended Primary)

A triangle frame drawn with a thin, muted stroke. A brighter point of light travels along the edges, tracing the breath cycle.

### How It Works

1. **Inhale**: A bright dot travels up the left edge from bottom-left vertex to apex. It leaves a fading trail — the edge behind it glows briefly then dims back to the base stroke color.
2. **Hold (top)**: The dot rests at the apex, pulsing gently. A subtle bloom at the vertex.
3. **Exhale**: The dot descends the right edge from apex to bottom-right. Same fading trail behavior.
4. **Hold (bottom)**: The dot travels the base from right to left, completing the circuit. Brief moment where the full triangle is faintly visible before the cycle restarts.

### Visual Properties

- **Triangle stroke**: 1-1.5pt line, muted warm tone (e.g. `opacity: 0.3` of the phase color). Always visible as a ghost frame so the user has spatial context.
- **Traveling dot**: 3-4pt diameter, phase-colored, full brightness. This is the only "bright" element.
- **Trail**: The edge segment behind the dot glows at ~60% brightness, fading over ~1 second to base stroke opacity. Creates a comet-tail effect.
- **No fill, no shadow, no glow radius** beyond the dot itself. The triangle interior is fully transparent — content behind is unobstructed.

### Why It Works for Ambient Use

- **Minimal visual footprint**: Just a thin triangle outline + one bright dot. ~95% of the bounding box is transparent.
- **Works at low opacity**: The dot's relative brightness against the faint stroke remains readable even at 30% window opacity.
- **Phase clarity without color**: Position alone tells you the phase. Color is reinforcement, not the primary signal.
- **Hypnotic without demanding**: The steady movement of a single point is calming to glance at — like watching a second hand on a clock.

### Size Considerations

- At 60pt: The triangle is compact. Dot is ~3pt. Trail is subtle. Good for "barely there" mode.
- At 120pt: More room for the trail to breathe. Dot can be 4pt. The triangle becomes a gentle geometric presence.
- At 200pt+: The triangle becomes a deliberate design element. Could add vertex markers (small circles at the three corners).

---

## Concept B: "The Prism" — Rotating Triangle (Simple Alternative)

A solid but translucent equilateral triangle that rotates to indicate phase direction.

### How It Works

1. **Inhale**: Triangle rotates to point upward (apex at top). Slight scale increase (0.85 → 1.0). Brightens.
2. **Hold**: Triangle holds position, gentle opacity pulse.
3. **Exhale**: Triangle rotates to point downward (apex at bottom). Scale decreases (1.0 → 0.85). Dims.
4. **Hold (bottom)**: Rests in down position, dim and still.

### Visual Properties

- **Fill**: Translucent, single color at ~20-30% opacity. Subtle enough to see through.
- **Stroke**: 1pt edge stroke at slightly higher opacity than fill (~50%).
- **No shadow, no glow**. The shape itself is the indicator.
- **Rotation**: Smooth 180-degree rotation over the phase duration. Uses ease-in-out.

### Why It Works for Ambient Use

- **Extremely simple**: One shape, one motion (rotation), one color.
- **Low visual weight**: Translucent fill means content shows through.
- **Directional metaphor is intuitive**: Up = inhale, Down = exhale.
- **Easy to implement**: Just rotation + scale + opacity. No path animation needed.

### Trade-offs

- Less visually interesting than Concept A — it's functional but not as hypnotic.
- Rotation of a symmetric shape can feel like it's "flipping" rather than "breathing."
- Best suited as a **fallback for very small sizes** (< 60pt) where path-tracing would be too subtle to read.

---

## Concept C: "The Path" — Drawing and Erasing (Most Distinctive)

The triangle doesn't exist as a permanent shape. It's drawn by the breath and dissolves behind it.

### How It Works

1. **Inhale**: Starting from bottom-left vertex, a line draws itself up the left edge toward the apex. The line has a soft taper — brighter at the leading edge, fading at the tail. By full inhale, the left edge is drawn.
2. **Hold (top)**: The drawn left edge holds. The apex vertex may have a small bloom.
3. **Exhale**: The line continues drawing down the right edge from apex to bottom-right. Simultaneously, the left edge fades out. By full exhale, only the right edge remains.
4. **Hold (bottom)**: The base draws from right to left. The right edge fades. For one brief moment, only the base is visible — then it too fades as the next inhale begins drawing the left edge again.

### Visual Properties

- **No permanent triangle**. The shape is always partial — always in the process of becoming or dissolving.
- **Line weight**: 1.5-2pt stroke. Slightly heavier than Concept A because there's no background frame for context.
- **Leading edge**: Full brightness, phase-colored.
- **Trailing fade**: The previously-drawn edge fades over the duration of the current phase. Dissolves to transparent, not to a ghost stroke.
- **Vertex blooms**: Optional — small 4-6pt circles at vertices that briefly appear as the drawing passes through them, then fade. Gives spatial anchoring without a permanent frame.

### Why It Works for Ambient Use

- **Maximum transparency**: At any given moment, only ~1/3 of the triangle exists. The rest is empty space.
- **Deeply calming to watch**: The constant creation and dissolution mirrors the impermanence of breath. It's meditative in itself.
- **Unmistakable identity**: No other breathing app does this. It's immediately recognizable.
- **Works at any opacity**: Since the shape is always partial, even at 50% opacity there's very little visual obstruction.

### Trade-offs

- **Higher implementation complexity**: Requires animated `trim(from:to:)` on a Path shape, with coordinated fade-out of previous segments.
- **Less clear phase indication at a glance**: With no permanent frame, a new user might not immediately understand the triangle shape. After one full cycle it becomes clear.
- **Needs minimum ~80pt size** to read the drawing/dissolving behavior. Below that, it just looks like a flickering line.

---

## Recommended Approach

### Primary: Concept A ("The Summit") with Concept C ("The Path") as an option

**Default behavior**: Concept A — the permanent ghost triangle with traveling light. This is the safest, most readable, and most ambient-friendly approach. Users immediately understand the shape and can track progress.

**Advanced/optional mode**: Concept C — the drawing/dissolving path. Offered as a "Minimal" style toggle in settings for users who want maximum transparency and visual poetry. This is the more distinctive option but requires slightly more screen real estate to read.

**Concept B** ("The Prism") could serve as a **micro mode** — when the indicator is very small (< 50pt), the rotation approach remains readable where path-tracing would be too fine.

### Style Toggle in Settings

Add a "Style" picker to Settings with three options:

| Style       | Concept   | Best For              |
|-------------|-----------|----------------------|
| **Summit**  | A         | Default, most readable |
| **Path**    | C         | Minimal, most distinctive |
| **Prism**   | B         | Tiny sizes, simplest |

---

## Color Direction

Move away from the current cyan/magenta/orange defaults. New defaults should feel warm, organic, and non-"AI":

| Phase   | Current (AI palette)       | New Direction               |
|---------|----------------------------|-----------------------------|
| Inhale  | Cyan (hue 0.55)            | Warm amber (hue ~0.08-0.10) |
| Hold    | Magenta (hue 0.75)         | Soft gold (hue ~0.12-0.14)  |
| Exhale  | Orange (hue 0.083)         | Dusty rose (hue ~0.95-0.98) |

The palette should feel like **candlelight**, not **neon signage**. Users can still customize via the hue sliders — these are just better defaults.

### Single-Color Mode

Consider offering a single-color mode where all phases use the same hue. Position on the triangle provides phase information; color becomes purely aesthetic. This further simplifies the visual and avoids the "traffic light" effect of three distinct colors.

---

## Animation Refinement

### Current Problem
- Binary scale (1.0 vs 0.6) with `.easeInOut` feels mechanical
- Label animation (0.6s) is decoupled from breath phase duration

### New Approach
- **Continuous progress**: Drive animation from a 0→1 progress value per phase, not binary states
- **Asymmetric easing**: Inhale eases in slowly (lungs filling against resistance), exhale eases out with a natural deceleration (passive release)
- **No scale animation** on the triangle itself — the traveling dot/drawing IS the animation
- **Label**: Crossfade with the phase transition, matching the phase duration. Or remove entirely — the triangle position tells the story.

---

## Settings Window Updates

The current stock `.formStyle(.grouped)` settings work functionally but feel disconnected from the breathing experience.

### Recommended Changes

1. **Live preview**: Show the actual triangle animating in the settings window header, so users see their changes in real time.
2. **Style picker**: Add the Summit/Path/Prism toggle as the first control.
3. **Phase color section**: Replace the tiny 20pt circle swatches with a hue spectrum gradient as the slider track.
4. **Dark background option**: Consider a dark settings background that matches the context where the triangle lives (floating over desktop).

---

## Menu Bar Icon

Replace the Unicode glyph `"◉"` with a proper triangle icon:

- Use SF Symbol `"triangle"` or a custom 18x18 template image of the triangle silhouette
- Consider: the menu bar icon could subtly reflect the current phase (opacity pulse) — but this may be too subtle to notice and not worth the implementation cost.

---

## Implementation Notes (for iOS/macOS agents)

### SwiftUI Path for Triangle

```
Path { path in
    path.move(to: CGPoint(x: midX, y: top))        // apex
    path.addLine(to: CGPoint(x: right, y: bottom))  // bottom-right
    path.addLine(to: CGPoint(x: left, y: bottom))   // bottom-left
    path.closeSubpath()
}
```

### Key SwiftUI APIs

- `trim(from:to:)` on Shape — for drawing/tracing animation
- `StrokeStyle(lineWidth:lineCap:)` — use `.round` line cap for the traveling dot effect
- `withAnimation(.timingCurve(...))` — for custom asymmetric easing
- `TimelineView(.animation)` — for continuous progress-driven animation instead of state-driven

### Performance Considerations

- Path animation is lightweight — no fill, no shadow, no blur
- The triangle is a 3-segment path — trivially cheap to render
- `trim` animation is GPU-accelerated in SwiftUI
- At 60fps, even continuous animation has negligible CPU impact for a 3-line path
