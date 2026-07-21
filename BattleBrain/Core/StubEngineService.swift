import Foundation

struct StubEngineService: EngineService {
    func analyzeReplay(id: String) async throws -> ReplayAnalysisResult {
        let turnCount = Int.random(in: 20...45)
        var winProb = 0.5
        var evaluations: [TurnEvaluation] = []

        let sampleMoves = [
            "Earthquake", "Close Combat", "U-turn", "Knock Off", "Stealth Rock",
            "Volt Switch", "Hydro Pump", "Ice Beam", "Thunderbolt", "Flamethrower",
            "Draco Meteor", "Iron Head", "Moonblast", "Swords Dance", "Roost",
        ]

        for turn in 1...turnCount {
            let swing = Double.random(in: -0.15...0.15)
            winProb = min(max(winProb + swing, 0.02), 0.98)

            let played = sampleMoves.randomElement()!
            let recommended = Bool.random() ? played : sampleMoves.randomElement()!

            evaluations.append(TurnEvaluation(
                turn: turn,
                winProbability: winProb,
                playedMove: played,
                recommendedMove: recommended,
                evalSwing: swing,
                bestLine: Array(sampleMoves.shuffled().prefix(3))
            ))
        }

        let accuracy = evaluations.filter { $0.playedMove == $0.recommendedMove }.count
        return ReplayAnalysisResult(
            replayId: id,
            turnEvaluations: evaluations,
            overallAccuracy: Double(accuracy) / Double(turnCount)
        )
    }

    func analyzeTurn(replayId: String, turn: Int) async throws -> TurnEvaluation {
        let result = try await analyzeReplay(id: replayId)
        guard let eval = result.turnEvaluations.first(where: { $0.turn == turn }) else {
            throw StubError.turnNotFound
        }
        return eval
    }

    enum StubError: Error {
        case turnNotFound
    }
}
