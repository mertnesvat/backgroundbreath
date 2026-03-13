import SwiftUI

struct TriangleBreathView: View {
    @ObservedObject var timer: BreathTimer
    @ObservedObject var settings: BreathSettings

    private var currentHue: Double {
        switch timer.phase {
        case .inhale:                              return settings.inhaleHue
        case .holdAfterInhale, .holdAfterExhale:   return settings.holdHue
        case .exhale:                              return settings.exhaleHue
        }
    }

    private var label: String {
        switch timer.phase {
        case .inhale:                              return "inhale"
        case .holdAfterInhale, .holdAfterExhale:   return "hold"
        case .exhale:                              return "exhale"
        }
    }

    var body: some View {
        let size = settings.orbSize

        VStack(spacing: 8) {
            if timer.isRunning {
                switch settings.selectedStyle {
                case .path:
                    TimelineView(.animation) { timeline in
                        TrianglePathStyle(
                            timer: timer,
                            hue: currentHue,
                            size: size,
                            glowIntensity: settings.glowIntensity,
                            date: timeline.date
                        )
                    }
                    .frame(width: size, height: size)
                case .summit:
                    TimelineView(.animation) { timeline in
                        TriangleSummitStyle(
                            timer: timer,
                            hue: currentHue,
                            size: size,
                            glowIntensity: settings.glowIntensity,
                            date: timeline.date
                        )
                    }
                    .frame(width: size, height: size)
                case .prism:
                    TrianglePrismStyle(
                        timer: timer,
                        hue: currentHue,
                        size: size,
                        glowIntensity: settings.glowIntensity
                    )
                    .frame(width: size, height: size)
                }
            } else {
                // Static snapshot when paused — no TimelineView overhead
                pausedView(size: size)
            }

            if settings.showLabel {
                Text(label)
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .tracking(1.5)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hue: currentHue, saturation: 0.8, brightness: 1.0).opacity(0.7))
                    .animation(.easeInOut(duration: 0.6), value: timer.phase)
            }
        }
        .frame(width: size + 28, height: size + 40)
        .background(.clear)
    }

    @ViewBuilder
    private func pausedView(size: Double) -> some View {
        let color = Color(hue: currentHue, saturation: 0.8, brightness: 1.0)
        switch settings.selectedStyle {
        case .path, .summit:
            // Show a dim static triangle outline when paused
            Canvas { context, canvasSize in
                let rect = CGRect(origin: .zero, size: canvasSize)
                let path = TriangleShape().path(in: rect)
                context.opacity = 0.2
                context.stroke(path, with: .color(color),
                               style: StrokeStyle(lineWidth: 1.0, lineCap: .round, lineJoin: .round))
            }
            .frame(width: size, height: size)
        case .prism:
            TrianglePrismStyle(timer: timer, hue: currentHue, size: size, glowIntensity: settings.glowIntensity)
                .frame(width: size, height: size)
                .opacity(0.4)
        }
    }
}

// MARK: - Path Style (Concept C)

struct TrianglePathStyle: View {
    @ObservedObject var timer: BreathTimer
    let hue: Double
    let size: Double
    let glowIntensity: Double
    let date: Date  // Triggers SwiftUI redraws from TimelineView — do not remove

    var body: some View {
        let progress = timer.phaseProgress
        let phase = timer.phase
        let segment = phase.triangleSegment
        let color = Color(hue: hue, saturation: 0.8, brightness: 1.0)

        // Current segment being drawn
        let currentFrom = segment.start
        let currentTo: Double = {
            if phase == .holdAfterInhale {
                return segment.end
            }
            return segment.start + (segment.end - segment.start) * progress
        }()

        // Previous segment fading out
        let prevSegment = previousSegment(for: phase)
        let prevOpacity = phase == .holdAfterInhale ? 1.0 : max(0, 1.0 - progress * 1.5)

        Canvas { context, canvasSize in
            let rect = CGRect(origin: .zero, size: canvasSize)
            let trianglePath = TriangleShape().path(in: rect)

            // Draw the previous segment (fading)
            if prevOpacity > 0 {
                let prevPath = trianglePath.trimmedPath(from: prevSegment.start, to: prevSegment.end)
                context.opacity = prevOpacity * 0.6
                context.stroke(
                    prevPath,
                    with: .color(color),
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                )
            }

            // Draw the current segment (being drawn)
            if currentTo > currentFrom {
                let currentPath = trianglePath.trimmedPath(from: currentFrom, to: currentTo)
                context.opacity = 1.0
                context.stroke(
                    currentPath,
                    with: .color(color),
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                )

                // Subtle glow on leading edge
                if glowIntensity > 0 {
                    let tipFrom = max(currentFrom, currentTo - 0.02)
                    let tipPath = trianglePath.trimmedPath(from: tipFrom, to: currentTo)
                    context.opacity = 0.4 * glowIntensity
                    context.addFilter(.blur(radius: 4))
                    context.stroke(
                        tipPath,
                        with: .color(color),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                }
            }
        }
    }

    private func previousSegment(for phase: BreathPhase) -> (start: Double, end: Double) {
        switch phase {
        case .inhale:           return (start: 2.0/3.0, end: 1.0)
        case .holdAfterInhale:  return (start: 0.0, end: 1.0/3.0)
        case .exhale:           return (start: 0.0, end: 1.0/3.0)
        case .holdAfterExhale:  return (start: 1.0/3.0, end: 2.0/3.0)
        }
    }
}

// MARK: - Summit Style (Concept A)

struct TriangleSummitStyle: View {
    @ObservedObject var timer: BreathTimer
    let hue: Double
    let size: Double
    let glowIntensity: Double
    let date: Date  // Triggers SwiftUI redraws from TimelineView — do not remove

    var body: some View {
        let progress = timer.phaseProgress
        let phase = timer.phase
        let segment = phase.triangleSegment
        let color = Color(hue: hue, saturation: 0.8, brightness: 1.0)
        let ghostColor = Color(hue: hue, saturation: 0.6, brightness: 0.8)

        // Dot position along the triangle
        let dotPos: Double = {
            if phase == .holdAfterInhale {
                return segment.start // hold at apex
            }
            return segment.start + (segment.end - segment.start) * progress
        }()

        Canvas { context, canvasSize in
            let rect = CGRect(origin: .zero, size: canvasSize)
            let trianglePath = TriangleShape().path(in: rect)

            // Ghost frame
            context.opacity = 0.25
            context.stroke(
                trianglePath,
                with: .color(ghostColor),
                style: StrokeStyle(lineWidth: 1.0, lineCap: .round, lineJoin: .round)
            )

            // Fading trail behind dot (wraps across path boundary)
            let trailLength = 0.08
            context.opacity = 0.4
            if dotPos >= trailLength {
                let trailPath = trianglePath.trimmedPath(from: dotPos - trailLength, to: dotPos)
                context.stroke(trailPath, with: .color(color),
                               style: StrokeStyle(lineWidth: 2.0, lineCap: .round))
            } else {
                // Wrap: draw tail end from near 1.0 + head from 0.0
                let wrapFrom = 1.0 - (trailLength - dotPos)
                let wrapPath = trianglePath.trimmedPath(from: wrapFrom, to: 1.0)
                context.stroke(wrapPath, with: .color(color),
                               style: StrokeStyle(lineWidth: 2.0, lineCap: .round))
                if dotPos > 0 {
                    let headPath = trianglePath.trimmedPath(from: 0, to: dotPos)
                    context.stroke(headPath, with: .color(color),
                                   style: StrokeStyle(lineWidth: 2.0, lineCap: .round))
                }
            }

            // Bright traveling dot
            let dotRadius = 0.015
            let dotFrom = max(0, dotPos - dotRadius)
            let dotTo = min(1, dotPos + dotRadius)
            let dotPath = trianglePath.trimmedPath(from: dotFrom, to: dotTo)
            context.opacity = 1.0
            context.stroke(
                dotPath,
                with: .color(color),
                style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
            )

            // Subtle glow around dot
            if glowIntensity > 0 {
                context.opacity = 0.3 * glowIntensity
                context.addFilter(.blur(radius: 6))
                context.stroke(
                    dotPath,
                    with: .color(color),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
            }
        }
    }
}

// MARK: - Prism Style (Concept B)

struct TrianglePrismStyle: View {
    @ObservedObject var timer: BreathTimer
    let hue: Double
    let size: Double
    let glowIntensity: Double

    private var rotation: Angle {
        switch timer.phase {
        case .inhale, .holdAfterInhale: return .degrees(0)
        case .exhale, .holdAfterExhale: return .degrees(180)
        }
    }

    private var scale: CGFloat {
        switch timer.phase {
        case .inhale, .holdAfterInhale: return 1.0
        case .exhale, .holdAfterExhale: return 0.85
        }
    }

    private var fillOpacity: Double {
        switch timer.phase {
        case .inhale:           return 0.28
        case .holdAfterInhale:  return 0.22
        case .exhale:           return 0.18
        case .holdAfterExhale:  return 0.22
        }
    }

    var body: some View {
        let color = Color(hue: hue, saturation: 0.8, brightness: 1.0)

        TriangleShape()
            .fill(color.opacity(fillOpacity))
            .overlay(
                TriangleShape()
                    .stroke(color.opacity(0.5), style: StrokeStyle(lineWidth: 1.0, lineJoin: .round))
            )
            .rotationEffect(rotation)
            .scaleEffect(scale)
            .animation(.easeInOut(duration: timer.currentPhaseDuration), value: timer.phase)
    }
}
