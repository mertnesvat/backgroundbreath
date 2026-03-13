import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: BreathSettings
    @ObservedObject var timer: BreathTimer

    var body: some View {
        Form {
            // Preview + primary control
            Section {
                livePreview

                Toggle(isOn: $settings.lockPosition) {
                    HStack(spacing: 6) {
                        Image(systemName: settings.lockPosition ? "lock.fill" : "lock.open")
                            .foregroundColor(settings.lockPosition ? .secondary : .accentColor)
                            .frame(width: 16)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(settings.lockPosition ? "Position locked" : "Position unlocked")
                            Text(settings.lockPosition
                                 ? "Clicks pass through to windows behind"
                                 : "Drag the triangle to reposition")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Section("Style") {
                stylePicker
            }

            Section("Display") {
                LabeledContent("Size") {
                    Slider(value: $settings.orbSize, in: 30...800)
                    Text("\(Int(settings.orbSize))pt")
                        .monospacedDigit()
                        .frame(width: 36, alignment: .trailing)
                }

                LabeledContent("Opacity") {
                    Slider(value: $settings.windowOpacity, in: 0.1...1.0)
                    Text("\(Int(settings.windowOpacity * 100))%")
                        .monospacedDigit()
                        .frame(width: 36, alignment: .trailing)
                }

                LabeledContent("Glow") {
                    Slider(value: $settings.glowIntensity, in: 0...2)
                    Text(String(format: "%.1f×", settings.glowIntensity))
                        .monospacedDigit()
                        .frame(width: 36, alignment: .trailing)
                }

                Toggle("Show phase label", isOn: $settings.showLabel)
            }

            Section("Colors") {
                phaseColorRow("Inhale", hue: $settings.inhaleHue)
                phaseColorRow("Exhale", hue: $settings.exhaleHue)
                phaseColorRow("Hold",   hue: $settings.holdHue)
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Live preview

    private var livePreview: some View {
        let previewSize: CGFloat = 64

        return HStack(spacing: 0) {
            Spacer()
            ZStack {
                // Dark backdrop to see the triangle clearly
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.85))
                    .frame(width: previewSize + 40, height: previewSize + 40)

                if timer.isRunning {
                    TimelineView(.animation) { timeline in
                        previewTriangle(size: previewSize, date: timeline.date)
                    }
                } else {
                    previewTriangleStatic(size: previewSize)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func previewTriangle(size: CGFloat, date: Date) -> some View {
        let hue = currentPreviewHue
        let progress = timer.phaseProgress
        let phase = timer.phase
        let color = Color(hue: hue, saturation: 0.8, brightness: 1.0)

        switch settings.selectedStyle {
        case .path:
            Canvas { context, canvasSize in
                let rect = CGRect(origin: .zero, size: canvasSize)
                let path = TriangleShape().path(in: rect)
                let segment = phase.triangleSegment
                let currentTo = phase == .holdAfterInhale
                    ? segment.end
                    : segment.start + (segment.end - segment.start) * progress
                if currentTo > segment.start {
                    let drawn = path.trimmedPath(from: segment.start, to: currentTo)
                    context.stroke(drawn, with: .color(color),
                                   style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                }
            }
            .frame(width: size, height: size)
        case .summit:
            Canvas { context, canvasSize in
                let rect = CGRect(origin: .zero, size: canvasSize)
                let path = TriangleShape().path(in: rect)
                let ghostColor = Color(hue: hue, saturation: 0.6, brightness: 0.8)
                // Ghost
                context.opacity = 0.25
                context.stroke(path, with: .color(ghostColor),
                               style: StrokeStyle(lineWidth: 1.0, lineCap: .round, lineJoin: .round))
                // Dot
                let segment = phase.triangleSegment
                let dotPos = phase == .holdAfterInhale
                    ? segment.start
                    : segment.start + (segment.end - segment.start) * progress
                let dotFrom = max(0, dotPos - 0.02)
                let dotTo = min(1, dotPos + 0.02)
                let dotPath = path.trimmedPath(from: dotFrom, to: dotTo)
                context.opacity = 1.0
                context.stroke(dotPath, with: .color(color),
                               style: StrokeStyle(lineWidth: 3, lineCap: .round))
            }
            .frame(width: size, height: size)
        case .prism:
            let rotation: Angle = (phase == .inhale || phase == .holdAfterInhale) ? .degrees(0) : .degrees(180)
            let scale: CGFloat = (phase == .inhale || phase == .holdAfterInhale) ? 1.0 : 0.85
            TriangleShape()
                .fill(color.opacity(0.25))
                .overlay(TriangleShape().stroke(color.opacity(0.5), lineWidth: 1.0))
                .frame(width: size, height: size)
                .rotationEffect(rotation)
                .scaleEffect(scale)
                .animation(.easeInOut(duration: timer.currentPhaseDuration), value: timer.phase)
        }
    }

    @ViewBuilder
    private func previewTriangleStatic(size: CGFloat) -> some View {
        let color = Color(hue: settings.inhaleHue, saturation: 0.8, brightness: 1.0)
        Canvas { context, canvasSize in
            let rect = CGRect(origin: .zero, size: canvasSize)
            let path = TriangleShape().path(in: rect)
            context.opacity = 0.3
            context.stroke(path, with: .color(color),
                           style: StrokeStyle(lineWidth: 1.0, lineCap: .round, lineJoin: .round))
        }
        .frame(width: size, height: size)
    }

    private var currentPreviewHue: Double {
        switch timer.phase {
        case .inhale:                              return settings.inhaleHue
        case .holdAfterInhale, .holdAfterExhale:   return settings.holdHue
        case .exhale:                              return settings.exhaleHue
        }
    }

    // MARK: - Style picker

    private var stylePicker: some View {
        Picker("Style", selection: $settings.selectedStyle) {
            ForEach(BreathStyle.allCases) { style in
                HStack(spacing: 8) {
                    styleIcon(for: style)
                        .frame(width: 16, height: 16)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(style.displayName)
                        Text(style.subtitle)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .tag(style)
            }
        }
        .pickerStyle(.radioGroup)
    }

    @ViewBuilder
    private func styleIcon(for style: BreathStyle) -> some View {
        let color = Color(hue: settings.inhaleHue, saturation: 0.8, brightness: 1.0)
        switch style {
        case .path:
            // Partial triangle (only left edge drawn)
            Canvas { context, canvasSize in
                let rect = CGRect(origin: .zero, size: canvasSize)
                let path = TriangleShape().path(in: rect)
                let partial = path.trimmedPath(from: 0, to: 0.33)
                context.stroke(partial, with: .color(color),
                               style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
            }
        case .summit:
            // Full triangle outline with a dot at apex
            Canvas { context, canvasSize in
                let rect = CGRect(origin: .zero, size: canvasSize)
                let path = TriangleShape().path(in: rect)
                context.opacity = 0.4
                context.stroke(path, with: .color(color),
                               style: StrokeStyle(lineWidth: 0.8, lineCap: .round, lineJoin: .round))
                // Dot at apex
                let dotPath = path.trimmedPath(from: 0.32, to: 0.35)
                context.opacity = 1.0
                context.stroke(dotPath, with: .color(color),
                               style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
            }
        case .prism:
            // Filled triangle
            TriangleShape()
                .fill(color.opacity(0.3))
                .overlay(TriangleShape().stroke(color.opacity(0.6), lineWidth: 0.8))
        }
    }

    // MARK: - Phase color row

    private func phaseColorRow(_ label: String, hue: Binding<Double>) -> some View {
        LabeledContent(label) {
            Slider(value: hue, in: 0...1)
            // Triangle-shaped swatch instead of circle
            Canvas { context, canvasSize in
                let rect = CGRect(origin: .zero, size: canvasSize)
                let path = TriangleShape().path(in: rect)
                context.fill(path, with: .color(Color(hue: hue.wrappedValue, saturation: 0.8, brightness: 1.0)))
            }
            .frame(width: 22, height: 22)
        }
    }
}

// MARK: - About

struct AboutView: View {
    @ObservedObject var settings: BreathSettings

    var body: some View {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"

        VStack(spacing: 20) {
            // Triangle icon instead of lungs
            Canvas { context, canvasSize in
                let rect = CGRect(origin: .zero, size: canvasSize)
                let path = TriangleShape().path(in: rect)
                let color = Color(hue: settings.inhaleHue, saturation: 0.7, brightness: 0.9)
                context.fill(path, with: .color(color.opacity(0.3)))
                context.stroke(path, with: .color(color),
                               style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            }
            .frame(width: 52, height: 52)

            VStack(spacing: 4) {
                Text("BackgroundBreath")
                    .font(.system(size: 17, weight: .semibold))
                Text("Version \(version)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Text("Slow, rhythmic breathing activates the parasympathetic nervous system — reducing cortisol, lowering heart rate, and sharpening focus. Even a few minutes a day builds lasting resilience.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)

            Divider()

            HStack(spacing: 4) {
                Text("Made by")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Link("Studio Next", destination: URL(string: "https://studionext.co.uk")!)
                    .font(.system(size: 12, weight: .medium))
            }
        }
        .padding(28)
        .frame(width: 320)
    }
}
