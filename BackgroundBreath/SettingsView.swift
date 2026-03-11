import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: BreathSettings

    var body: some View {
        Form {
            Section("Breathing Pattern") {
                Picker("Pattern", selection: $settings.selectedPatternId) {
                    ForEach(BreathPattern.all) { p in
                        Text(p.name).tag(p.id)
                    }
                }
                .pickerStyle(.menu)

                if let p = BreathPattern.all.first(where: { $0.id == settings.selectedPatternId }) {
                    patternSummaryRow(p)
                }
            }

            Section("Appearance") {
                phasePreviewOrbs

                LabeledContent("Opacity") {
                    Slider(value: $settings.windowOpacity, in: 0.1...1.0)
                    Text("\(Int(settings.windowOpacity * 100))%")
                        .frame(width: 36, alignment: .trailing)
                }

                LabeledContent("Size") {
                    Slider(value: $settings.orbSize, in: 30...800)
                    Text("\(Int(settings.orbSize))pt")
                        .frame(width: 36, alignment: .trailing)
                }

                LabeledContent("Glow") {
                    Slider(value: $settings.glowIntensity, in: 0...2)
                    Text(String(format: "%.1f×", settings.glowIntensity))
                        .frame(width: 36, alignment: .trailing)
                }

                Toggle("Show label", isOn: $settings.showLabel)
                Toggle("Lock position", isOn: $settings.lockPosition)
            }

            Section("Phase Colors") {
                phaseColorRow("Inhale", hue: $settings.inhaleHue)
                phaseColorRow("Exhale", hue: $settings.exhaleHue)
                phaseColorRow("Hold",   hue: $settings.holdHue)
            }

            Section("About") {
                aboutContent
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - About

    private var aboutContent: some View {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "lungs.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hue: settings.inhaleHue, saturation: 0.7, brightness: 0.9))
                VStack(alignment: .leading, spacing: 2) {
                    Text("BackgroundBreath")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Version \(version)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            Text("Slow, rhythmic breathing activates the parasympathetic nervous system — reducing cortisol, lowering heart rate, and sharpening focus. Even a few minutes a day builds lasting resilience.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)

            Divider()

            HStack {
                Text("Made by")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Link("Studio Next", destination: URL(string: "https://studionext.co.uk")!)
                    .font(.system(size: 11, weight: .medium))
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Pattern summary

    @ViewBuilder
    private func patternSummaryRow(_ p: BreathPattern) -> some View {
        HStack(spacing: 8) {
            phaseBadge("↑", value: p.inhale)
            if p.holdAfterInhale > 0 { phaseBadge("⏸", value: p.holdAfterInhale) }
            phaseBadge("↓", value: p.exhale)
            if p.holdAfterExhale > 0 { phaseBadge("⏸", value: p.holdAfterExhale) }
            Spacer()
        }
        .padding(.vertical, 2)
    }

    private func phaseBadge(_ icon: String, value: Double) -> some View {
        HStack(spacing: 3) {
            Text(icon)
            Text(value == Double(Int(value)) ? "\(Int(value))s" : String(format: "%.1fs", value))
        }
        .font(.system(size: 11, weight: .medium, design: .rounded))
        .foregroundColor(.secondary)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(Color.secondary.opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: - Phase color row

    private func phaseColorRow(_ label: String, hue: Binding<Double>) -> some View {
        LabeledContent(label) {
            Slider(value: hue, in: 0...1)
            Circle()
                .fill(Color(hue: hue.wrappedValue, saturation: 0.8, brightness: 1.0))
                .frame(width: 20, height: 20)
        }
    }

    // MARK: - Phase preview orbs

    private var phasePreviewOrbs: some View {
        let size: CGFloat = 36
        let glow = settings.glowIntensity
        let phases: [(Double, String)] = [
            (settings.inhaleHue, "inhale"),
            (settings.holdHue,   "hold"),
            (settings.exhaleHue, "exhale"),
        ]

        return HStack(spacing: 0) {
            Spacer()
            HStack(spacing: 16) {
                ForEach(phases, id: \.1) { hue, label in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(RadialGradient(
                                colors: [
                                    Color(hue: hue, saturation: 0.8, brightness: 1.0),
                                    Color(hue: hue, saturation: 1.0, brightness: 0.9).opacity(0.5),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: size / 2
                            ))
                            .frame(width: size, height: size)
                            .shadow(color: Color(hue: hue, saturation: 0.8, brightness: 1.0).opacity(0.6 * glow), radius: 10)
                        Text(label)
                            .font(.system(size: 8, weight: .regular, design: .rounded))
                            .tracking(1.0)
                            .textCase(.uppercase)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
