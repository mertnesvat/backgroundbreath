import XCTest
@testable import BackgroundBreath

final class BreathSettingsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Clear relevant keys before each test
        let keys = [
            "windowOpacity", "orbSize", "glowIntensity",
            "inhaleHue", "exhaleHue", "holdHue",
            "selectedPatternId", "showLabel", "lockPosition",
            "selectedStyle", "v2ColorMigration"
        ]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    // MARK: - Default selected style

    func testDefaultSelectedStyleIsPath() {
        let settings = BreathSettings()
        XCTAssertEqual(settings.selectedStyle, .path)
    }

    // MARK: - Persistence

    func testSelectedStylePersistsToUserDefaults() {
        let settings = BreathSettings()
        settings.selectedStyle = .prism
        let stored = UserDefaults.standard.string(forKey: "selectedStyle")
        XCTAssertEqual(stored, "prism")
    }

    func testSelectedStyleRestoresFromUserDefaults() {
        UserDefaults.standard.set("summit", forKey: "selectedStyle")
        let settings = BreathSettings()
        XCTAssertEqual(settings.selectedStyle, .summit)
    }

    // MARK: - Default hue values

    func testDefaultHueValues() {
        let settings = BreathSettings()
        XCTAssertEqual(settings.inhaleHue, 0.08, accuracy: 1e-10)
        XCTAssertEqual(settings.exhaleHue, 0.97, accuracy: 1e-10)
        XCTAssertEqual(settings.holdHue, 0.13, accuracy: 1e-10)
    }

    // MARK: - v2 Color migration

    func testV2MigrationConvertsOldDefaults() {
        // Simulate old defaults
        UserDefaults.standard.set(0.55, forKey: "inhaleHue")
        UserDefaults.standard.set(0.083, forKey: "exhaleHue")
        UserDefaults.standard.set(0.75, forKey: "holdHue")

        let settings = BreathSettings()
        XCTAssertEqual(settings.inhaleHue, 0.08, accuracy: 1e-10)
        XCTAssertEqual(settings.exhaleHue, 0.97, accuracy: 1e-10)
        XCTAssertEqual(settings.holdHue, 0.13, accuracy: 1e-10)
    }

    func testV2MigrationRunsOnlyOnce() {
        UserDefaults.standard.set(0.55, forKey: "inhaleHue")
        _ = BreathSettings() // first init — migrates
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "v2ColorMigration"))

        // Set old values again — migration should NOT run a second time
        UserDefaults.standard.set(0.55, forKey: "inhaleHue")
        let settings2 = BreathSettings()
        XCTAssertEqual(settings2.inhaleHue, 0.55, accuracy: 1e-10,
                       "Second init should not migrate because flag is already set")
    }
}
