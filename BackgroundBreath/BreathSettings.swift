import Foundation
import Combine

final class BreathSettings: ObservableObject {
    @Published var windowOpacity: Double {
        didSet { UserDefaults.standard.set(windowOpacity, forKey: "windowOpacity") }
    }
    @Published var orbSize: Double {
        didSet { UserDefaults.standard.set(orbSize, forKey: "orbSize") }
    }
    @Published var glowIntensity: Double {
        didSet { UserDefaults.standard.set(glowIntensity, forKey: "glowIntensity") }
    }
    @Published var colorHue: Double {
        didSet { UserDefaults.standard.set(colorHue, forKey: "colorHue") }
    }

    init() {
        windowOpacity  = UserDefaults.standard.object(forKey: "windowOpacity")  as? Double ?? 0.5
        orbSize        = UserDefaults.standard.object(forKey: "orbSize")        as? Double ?? 60
        glowIntensity  = UserDefaults.standard.object(forKey: "glowIntensity")  as? Double ?? 1.0
        colorHue       = UserDefaults.standard.object(forKey: "colorHue")       as? Double ?? 0.083
    }
}
