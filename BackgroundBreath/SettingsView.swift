import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: BreathSettings

    var body: some View {
        Form {
            Section("Style") {
                Picker("Style", selection: $settings.selectedStyle) {
                    ForEach(BreathStyle.allCases) { style in
                        VStack(alignment: .leading) {
                            Text(style.displayName)
                            Text(style.subtitle)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .tag(style)
                    }
                }
                .pickerStyle(.radioGroup)
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
        }
        .formStyle(.grouped)
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

// MARK: - About

struct AboutView: View {
    @ObservedObject var settings: BreathSettings

    var body: some View {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"

        VStack(spacing: 20) {
            Image(systemName: "lungs.fill")
                .font(.system(size: 52))
                .foregroundColor(Color(hue: settings.inhaleHue, saturation: 0.7, brightness: 0.9))

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
