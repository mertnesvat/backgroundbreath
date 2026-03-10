import Foundation
import Combine

enum BreathPhase { case inhale, exhale }

final class BreathTimer: ObservableObject {
    @Published var phase: BreathPhase = .inhale
    @Published var isRunning: Bool = false

    private var timer: Timer?
    private let interval: TimeInterval = 5.5

    func start() {
        guard !isRunning else { return }
        isRunning = true
        phase = .inhale
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
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.phase = (self.phase == .inhale) ? .exhale : .inhale
            self.scheduleNext()
        }
    }
}
