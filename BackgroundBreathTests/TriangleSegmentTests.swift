import XCTest
@testable import BackgroundBreath

final class TriangleSegmentTests: XCTestCase {

    // MARK: - Individual segment ranges

    func testInhaleSegment() {
        let seg = BreathPhase.inhale.triangleSegment
        XCTAssertEqual(seg.start, 0.0, accuracy: 1e-10)
        XCTAssertEqual(seg.end, 1.0 / 3.0, accuracy: 1e-10)
    }

    func testHoldAfterInhaleSegment() {
        let seg = BreathPhase.holdAfterInhale.triangleSegment
        XCTAssertEqual(seg.start, 1.0 / 3.0, accuracy: 1e-10)
        XCTAssertEqual(seg.end, 1.0 / 3.0, accuracy: 1e-10)
    }

    func testExhaleSegment() {
        let seg = BreathPhase.exhale.triangleSegment
        XCTAssertEqual(seg.start, 1.0 / 3.0, accuracy: 1e-10)
        XCTAssertEqual(seg.end, 2.0 / 3.0, accuracy: 1e-10)
    }

    func testHoldAfterExhaleSegment() {
        let seg = BreathPhase.holdAfterExhale.triangleSegment
        XCTAssertEqual(seg.start, 2.0 / 3.0, accuracy: 1e-10)
        XCTAssertEqual(seg.end, 1.0, accuracy: 1e-10)
    }

    // MARK: - Contiguity

    func testSegmentsAreContiguous() {
        let inhale = BreathPhase.inhale.triangleSegment
        let holdIn = BreathPhase.holdAfterInhale.triangleSegment
        let exhale = BreathPhase.exhale.triangleSegment
        let holdEx = BreathPhase.holdAfterExhale.triangleSegment

        XCTAssertEqual(inhale.end, holdIn.start, accuracy: 1e-10)
        XCTAssertEqual(holdIn.end, exhale.start, accuracy: 1e-10)
        XCTAssertEqual(exhale.end, holdEx.start, accuracy: 1e-10)
    }

    // MARK: - Full coverage

    func testSegmentsCoverFullRange() {
        let inhale = BreathPhase.inhale.triangleSegment
        let holdEx = BreathPhase.holdAfterExhale.triangleSegment

        XCTAssertEqual(inhale.start, 0.0, accuracy: 1e-10)
        XCTAssertEqual(holdEx.end, 1.0, accuracy: 1e-10)
    }

    // MARK: - Hold after inhale is zero-width

    func testHoldAfterInhaleIsZeroWidth() {
        let seg = BreathPhase.holdAfterInhale.triangleSegment
        XCTAssertEqual(seg.start, seg.end, accuracy: 1e-10)
    }
}
