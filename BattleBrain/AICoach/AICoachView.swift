import SwiftUI

struct AICoachView: View {
    var body: some View {
        ContentUnavailableView(
            "AI Coach",
            systemImage: "brain.head.profile",
            description: Text("Get natural-language coaching powered by engine analysis of your replays.")
        )
        .navigationTitle("Coach")
    }
}
