import SwiftUI

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let top = rect.minY
        let left = rect.minX
        let right = rect.maxX
        let bottom = rect.maxY

        var path = Path()
        // Start at bottom-left, go to apex, then bottom-right, then close (base)
        path.move(to: CGPoint(x: left, y: bottom))       // bottom-left
        path.addLine(to: CGPoint(x: midX, y: top))       // apex
        path.addLine(to: CGPoint(x: right, y: bottom))   // bottom-right
        path.closeSubpath()                                // base back to bottom-left
        return path
    }
}

// Path winding:
// 0.0–0.33: left edge ascending (inhale)
// 0.33–0.66: right edge descending (exhale)
// 0.66–1.0: base right-to-left (hold after exhale)

extension BreathPhase {
    var triangleSegment: (start: Double, end: Double) {
        switch self {
        case .inhale:           return (start: 0.0,  end: 1.0 / 3.0)
        case .holdAfterInhale:  return (start: 1.0 / 3.0, end: 1.0 / 3.0) // at apex
        case .exhale:           return (start: 1.0 / 3.0, end: 2.0 / 3.0)
        case .holdAfterExhale:  return (start: 2.0 / 3.0, end: 1.0)
        }
    }
}
