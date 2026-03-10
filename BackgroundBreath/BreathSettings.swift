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
    @Published var inhaleHue: Double {
        didSet { UserDefaults.standard.set(inhaleHue, forKey: "inhaleHue") }
    }
    @Published var exhaleHue: Double {
        didSet { UserDefaults.standard.set(exhaleHue, forKey: "exhaleHue") }
    }
    @Published var holdHue: Double {
        didSet { UserDefaults.standard.set(holdHue, forKey: "holdHue") }
    }
    @Published var selectedPatternId: String {
        didSet { UserDefaults.standard.set(selectedPatternId, forKey: "selectedPatternId") }
    }
    @Published var showLabel: Bool {
        didSet { UserDefaults.standard.set(showLabel, forKey: "showLabel") }
    }
    @Published var lockPosition: Bool {
        didSet { UserDefaults.standard.set(lockPosition, forKey: "lockPosition") }
    }

    init() {
        windowOpacity     = UserDefaults.standard.object(forKey: "windowOpacity")     as? Double ?? 0.5
        orbSize           = UserDefaults.standard.object(forKey: "orbSize")           as? Double ?? 60
        glowIntensity     = UserDefaults.standard.object(forKey: "glowIntensity")     as? Double ?? 1.0
        inhaleHue         = UserDefaults.standard.object(forKey: "inhaleHue")         as? Double ?? 0.55
        exhaleHue         = UserDefaults.standard.object(forKey: "exhaleHue")         as? Double ?? 0.083
        holdHue           = UserDefaults.standard.object(forKey: "holdHue")           as? Double ?? 0.75
        selectedPatternId = UserDefaults.standard.object(forKey: "selectedPatternId") as? String ?? "resonance"
        showLabel         = UserDefaults.standard.object(forKey: "showLabel")         as? Bool   ?? true
        lockPosition      = UserDefaults.standard.object(forKey: "lockPosition")      as? Bool   ?? false
    }
}
