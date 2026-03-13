import Foundation
import Combine

enum BreathPhase { case inhale, holdAfterInhale, exhale, holdAfterExhale }

final class BreathTimer: ObservableObject {
    @Published var phase: BreathPhase = .inhale
    @Published var isRunning: Bool = false
    @Published private(set) var currentPhaseDuration: TimeInterval = 5.5
    @Published private(set) var phaseStartDate: Date = Date()

    var phaseProgress: Double {
        let elapsed = Date().timeIntervalSince(phaseStartDate)
        return min(max(elapsed / currentPhaseDuration, 0), 1)
    }

    private var timer: Timer?
    private var pattern: BreathPattern = BreathPattern.all[0]
    private var phaseIndex: Int = 0

    func setPattern(_ p: BreathPattern) {
        let wasRunning = isRunning
        pause()
        pattern = p
        phaseIndex = 0
        if wasRunning { start() }
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        phaseIndex = 0
        scheduleNext()
    }

    func pause() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func toggle() {
        isRunning ? pause() : start()
    }

    private func scheduleNext() {
        let seq = pattern.phaseSequence
        let (nextPhase, duration) = seq[phaseIndex]
        phase = nextPhase
        currentPhaseDuration = duration
        phaseStartDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.phaseIndex = (self.phaseIndex + 1) % seq.count
                self.scheduleNext()
            }
        }
    }
}
