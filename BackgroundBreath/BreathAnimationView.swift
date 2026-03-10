import SwiftUI

struct BreathAnimationView: View {
    @ObservedObject var timer: BreathTimer

    private var scale: CGFloat { timer.phase == .inhale ? 1.0 : 0.6 }
    private var label: String { timer.phase == .inhale ? "inhale" : "exhale" }

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1.0, green: 0.78, blue: 0.39),   // warm amber core
                            Color(red: 1.0, green: 0.51, blue: 0.24).opacity(0.5),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.6), radius: 16)
                .shadow(color: Color(red: 1.0, green: 0.5, blue: 0.2).opacity(0.25), radius: 40)
                .scaleEffect(scale)
                .animation(.easeInOut(duration: timer.interval), value: timer.phase)

            Text(label)
                .font(.system(size: 9, weight: .regular, design: .rounded))
                .tracking(1.5)
                .textCase(.uppercase)
                .foregroundColor(Color(red: 1.0, green: 0.78, blue: 0.39).opacity(0.7))
                .animation(.easeInOut(duration: 0.6), value: timer.phase)
        }
        .frame(width: 88, height: 100)
        .background(.clear)
    }
}
