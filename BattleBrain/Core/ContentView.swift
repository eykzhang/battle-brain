import SwiftUI
import SwiftData

// Temporary debug view proving the bundled dataset loads into SwiftData.
// Replace with the real Competitive Database UI (build order step 2).
struct ContentView: View {
    @Query private var species: [Species]
    @Query private var sets: [CompetitiveSet]
    @Query private var usageStats: [UsageStat]

    var body: some View {
        VStack(spacing: 8) {
            Text("BattleBrain").font(.title)
            Text("\(species.count) species loaded")
            Text("\(sets.count) competitive sets loaded")
            Text("\(usageStats.count) usage stat entries loaded")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
