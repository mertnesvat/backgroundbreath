import XCTest
@testable import BackgroundBreath

final class BreathStyleTests: XCTestCase {

    // MARK: - Cases & RawValues

    func testAllCasesExist() {
        let cases = BreathStyle.allCases
        XCTAssertEqual(cases.count, 3)
        XCTAssertTrue(cases.contains(.path))
        XCTAssertTrue(cases.contains(.summit))
        XCTAssertTrue(cases.contains(.prism))
    }

    func testRawValues() {
        XCTAssertEqual(BreathStyle.path.rawValue, "path")
        XCTAssertEqual(BreathStyle.summit.rawValue, "summit")
        XCTAssertEqual(BreathStyle.prism.rawValue, "prism")
    }

    func testInitFromRawValue() {
        XCTAssertEqual(BreathStyle(rawValue: "path"), .path)
        XCTAssertEqual(BreathStyle(rawValue: "summit"), .summit)
        XCTAssertEqual(BreathStyle(rawValue: "prism"), .prism)
        XCTAssertNil(BreathStyle(rawValue: "invalid"))
    }

    // MARK: - Display strings

    func testDisplayNames() {
        XCTAssertEqual(BreathStyle.path.displayName, "Path")
        XCTAssertEqual(BreathStyle.summit.displayName, "Summit")
        XCTAssertEqual(BreathStyle.prism.displayName, "Prism")
    }

    func testSubtitles() {
        XCTAssertEqual(BreathStyle.path.subtitle, "Most distinctive")
        XCTAssertEqual(BreathStyle.summit.subtitle, "Most readable")
        XCTAssertEqual(BreathStyle.prism.subtitle, "Simplest")
    }

    // MARK: - Default

    func testDefaultStyleIsPath() {
        let style = BreathStyle(rawValue: "") ?? .path
        XCTAssertEqual(style, .path)
    }
}
