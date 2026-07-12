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
        }
    }
}

#Preview {
    MainTabView()
}
