import SwiftUI

struct BattleCompanionView: View {
    var body: some View {
        ContentUnavailableView(
            "Battle Companion",
            systemImage: "shield.checkered",
            description: Text("Track opponent team reveals, check coverage gaps, and reference speed tiers mid-battle.")
        )
        .navigationTitle("Companion")
    }
}
