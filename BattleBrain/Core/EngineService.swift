import Foundation

struct TurnEvaluation: Sendable {
    let turn: Int
    let winProbability: Double
    let playedMove: String
    let recommendedMove: String
    let evalSwing: Double
    let bestLine: [String]
}

struct ReplayAnalysisResult: Sendable {
    let replayId: String
    let turnEvaluations: [TurnEvaluation]
    let overallAccuracy: Double
}

protocol EngineService: Sendable {
    func analyzeReplay(id: String) async throws -> ReplayAnalysisResult
    func analyzeTurn(replayId: String, turn: Int) async throws -> TurnEvaluation
}
