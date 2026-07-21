import SwiftUI

struct ReplayAnalysisView: View {
    var body: some View {
        ContentUnavailableView(
            "Replay Analysis",
            systemImage: "chart.line.uptrend.xyaxis",
            description: Text("Paste a replay URL to see turn-by-turn analysis with engine-powered win probability.")
        )
        .navigationTitle("Replays")
    }
}
