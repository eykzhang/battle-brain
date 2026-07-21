import SwiftUI
import SwiftData

struct TeamListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Team.createdAt, order: .reverse) private var teams: [Team]
    @Query(sort: \Species.name) private var allSpecies: [Species]

    private var speciesById: [String: Species] { allSpecies.byId }

    var body: some View {
        List {
            ForEach(teams) { team in
                NavigationLink {
                    TeamEditorView(team: team)
                } label: {
                    teamRow(team)
                }
            }
            .onDelete(perform: deleteTeams)
        }
        .navigationTitle("Teams")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    addTeam()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if teams.isEmpty {
                ContentUnavailableView(
                    "No Teams Yet",
                    systemImage: "person.3",
                    description: Text("Tap + to build your first team.")
                )
            }
        }
    }

    @ViewBuilder
    private func teamRow(_ team: Team) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(team.name.isEmpty ? "Untitled Team" : team.name)
            Text("\(formatLabel(team.format)) · \(team.members.count) Pokémon")
                .font(.caption)
                .foregroundStyle(.secondary)
            if !team.members.isEmpty {
                HStack(spacing: 4) {
                    ForEach(team.members) { member in
                        if let species = speciesById[member.speciesId] {
                            TypeBadge(type: species.primaryType)
                        }
                    }
                }
            }
        }
    }

    private func addTeam() {
        let team = Team(name: "", format: "gen9ou")
        modelContext.insert(team)
    }

    private func deleteTeams(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(teams[index])
        }
    }

    private func formatLabel(_ format: String) -> String {
        switch format {
        case "gen9ou": return "OU"
        case "gen9vgc": return "VGC"
        default: return format
        }
    }
}
