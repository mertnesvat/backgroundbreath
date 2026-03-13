import XCTest
@testable import BackgroundBreath

final class BreathTimerTests: XCTestCase {

    // MARK: - Phase progress

    func testPhaseProgressStartsNearZero() {
        let timer = BreathTimer()
        timer.start()
        // Immediately after start, progress should be very close to 0
        XCTAssertLessThan(timer.phaseProgress, 0.1)
        timer.pause()
    }

    func testPhaseProgressIsClampedToUnitRange() {
        let timer = BreathTimer()
        // phaseStartDate defaults to Date(), currentPhaseDuration to 5.5
        // Progress should be in 0...1
        let progress = timer.phaseProgress
        XCTAssertGreaterThanOrEqual(progress, 0.0)
        XCTAssertLessThanOrEqual(progress, 1.0)
    }

    // MARK: - Phase start date

    func testPhaseStartDateIsSetOnStart() {
        let timer = BreathTimer()
        let before = Date()
        timer.start()
        let after = Date()
        XCTAssertGreaterThanOrEqual(timer.phaseStartDate, before)
        XCTAssertLessThanOrEqual(timer.phaseStartDate, after)
        timer.pause()
    }

    // MARK: - Start / pause

    func testStartSetsIsRunning() {
        let timer = BreathTimer()
        XCTAssertFalse(timer.isRunning)
        timer.start()
        XCTAssertTrue(timer.isRunning)
        timer.pause()
        XCTAssertFalse(timer.isRunning)
    }

    func testToggle() {
        let timer = BreathTimer()
        timer.toggle()
        XCTAssertTrue(timer.isRunning)
        timer.toggle()
        XCTAssertFalse(timer.isRunning)
    }

    func testStartTwiceDoesNotReset() {
        let timer = BreathTimer()
        timer.start()
        let firstStart = timer.phaseStartDate
        timer.start() // second call should be a no-op
        XCTAssertEqual(timer.phaseStartDate, firstStart)
        timer.pause()
    }
}
