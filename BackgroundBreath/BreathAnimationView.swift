import SwiftUI

struct BreathAnimationView: View {
    @ObservedObject var timer: BreathTimer
    @ObservedObject var settings: BreathSettings

    private var scale: CGFloat { timer.phase == .inhale ? 1.0 : 0.6 }

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
        let hue = currentHue
        let glow = settings.glowIntensity
        let coreColor = Color(hue: hue, saturation: 0.8, brightness: 1.0)
        let midColor = Color(hue: hue, saturation: 1.0, brightness: 0.9).opacity(0.5)

        VStack(spacing: 8) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [coreColor, midColor, .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: coreColor.opacity(0.6 * glow), radius: 16)
                .shadow(color: midColor.opacity(0.25 * glow), radius: 40)
                .scaleEffect(scale)
                .animation(.easeInOut(duration: timer.currentPhaseDuration), value: timer.phase)

            if settings.showLabel {
                Text(label)
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .tracking(1.5)
                    .textCase(.uppercase)
                    .foregroundColor(coreColor.opacity(0.7))
                    .animation(.easeInOut(duration: 0.6), value: timer.phase)
            }
        }
        .frame(width: size + 28, height: size + 40)
        .background(.clear)
    }
}
