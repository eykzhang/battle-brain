import SwiftUI
import SwiftData

@main
struct BattleBrainApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Species.self,
            Move.self,
            CompetitiveSet.self,
            UsageStat.self,
            Team.self,
            TeamMember.self,
        ])
        let container = try! ModelContainer(for: schema)
        try! DatasetBootstrapper.bootstrapIfNeeded(context: container.mainContext)
        return container
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
