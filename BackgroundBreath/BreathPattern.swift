import Foundation

struct BreathPattern: Identifiable {
    let id: String
    let name: String
    let inhale: Double
    let holdAfterInhale: Double   // 0 = skip this phase
    let exhale: Double
    let holdAfterExhale: Double   // 0 = skip this phase

    var phaseSequence: [(BreathPhase, Double)] {
        var seq: [(BreathPhase, Double)] = []
        seq.append((.inhale, inhale))
        if holdAfterInhale > 0 { seq.append((.holdAfterInhale, holdAfterInhale)) }
        seq.append((.exhale, exhale))
        if holdAfterExhale > 0 { seq.append((.holdAfterExhale, holdAfterExhale)) }
        return seq
    }

    static let all: [BreathPattern] = [
        BreathPattern(id: "resonance",     name: "Resonance (5.5–5.5)",  inhale: 5.5, holdAfterInhale: 0, exhale: 5.5, holdAfterExhale: 0),
        BreathPattern(id: "coherent",      name: "Coherent (6–6)",        inhale: 6,   holdAfterInhale: 0, exhale: 6,   holdAfterExhale: 0),
        BreathPattern(id: "box",           name: "Box (4–4–4–4)",         inhale: 4,   holdAfterInhale: 4, exhale: 4,   holdAfterExhale: 4),
        BreathPattern(id: "478",           name: "4–7–8 Relaxation",      inhale: 4,   holdAfterInhale: 7, exhale: 8,   holdAfterExhale: 0),
        BreathPattern(id: "physiological", name: "Physiological Sigh",    inhale: 2,   holdAfterInhale: 1, exhale: 8,   holdAfterExhale: 0),
        BreathPattern(id: "energizing",    name: "Energizing (4–2–6)",    inhale: 4,   holdAfterInhale: 2, exhale: 6,   holdAfterExhale: 0),
    ]
}
