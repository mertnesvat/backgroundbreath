import Foundation

enum BreathStyle: String, CaseIterable, Identifiable {
    case path    // Concept C — drawing/erasing triangle
    case summit  // Concept A — tracing light on permanent frame
    case prism   // Concept B — rotating solid triangle

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .path:   return "Path"
        case .summit: return "Summit"
        case .prism:  return "Prism"
        }
    }

    var subtitle: String {
        switch self {
        case .path:   return "Most distinctive"
        case .summit: return "Most readable"
        case .prism:  return "Simplest"
        }
    }
}
