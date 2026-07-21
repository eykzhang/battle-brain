import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DatabaseListView()
            }
            .tabItem {
                Label("Database", systemImage: "magnifyingglass")
            }

            NavigationStack {
                TeamListView()
            }
            .tabItem {
                Label("Teams", systemImage: "person.3.fill")
            }

            NavigationStack {
                ReplayAnalysisView()
            }
            .tabItem {
                Label("Replays", systemImage: "chart.line.uptrend.xyaxis")
            }

            NavigationStack {
                AICoachView()
            }
            .tabItem {
                Label("Coach", systemImage: "brain.head.profile")
            }

            NavigationStack {
                BattleCompanionView()
            }
            .tabItem {
                Label("Companion", systemImage: "shield.checkered")
            }
        }
    }
}

#Preview {
    MainTabView()
}
