import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: BreathSettings

    var body: some View {
        Form {
            Section("Appearance") {
                previewOrb

                LabeledContent("Opacity") {
                    Slider(value: $settings.windowOpacity, in: 0.1...1.0)
                    Text("\(Int(settings.windowOpacity * 100))%")
                        .frame(width: 36, alignment: .trailing)
                }

                LabeledContent("Size") {
                    Slider(value: $settings.orbSize, in: 30...120)
                    Text("\(Int(settings.orbSize))pt")
                        .frame(width: 36, alignment: .trailing)
                }

                LabeledContent("Glow") {
                    Slider(value: $settings.glowIntensity, in: 0...2)
                    Text(String(format: "%.1f×", settings.glowIntensity))
                        .frame(width: 36, alignment: .trailing)
                }

                LabeledContent("Color") {
                    Slider(value: $settings.colorHue, in: 0...1)
                    Circle()
                        .fill(Color(hue: settings.colorHue, saturation: 0.8, brightness: 1.0))
                        .frame(width: 20, height: 20)
                }
            }
        }
        .formStyle(.grouped)
    }

    private var previewOrb: some View {
        let size = settings.orbSize
        let hue = settings.colorHue
        let glow = settings.glowIntensity
        let coreColor = Color(hue: hue, saturation: 0.8, brightness: 1.0)
        let midColor = Color(hue: hue, saturation: 1.0, brightness: 0.9).opacity(0.5)

        return HStack {
            Spacer()
            Circle()
                .fill(RadialGradient(
                    colors: [coreColor, midColor, .clear],
                    center: .center, startRadius: 0, endRadius: size / 2
                ))
                .frame(width: size, height: size)
                .shadow(color: coreColor.opacity(0.6 * glow), radius: 16)
                .shadow(color: midColor.opacity(0.25 * glow), radius: 40)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
