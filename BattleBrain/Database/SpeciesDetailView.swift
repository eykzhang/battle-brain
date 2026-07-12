import SwiftUI
import SwiftData

struct SpeciesDetailView: View {
    let speciesId: String

    @Query private var matchedSpecies: [Species]
    @Query private var sets: [CompetitiveSet]
    @Query private var usage: [UsageStat]
    @Query(sort: \Species.name) private var allSpecies: [Species]

    @State private var selectedFormat = "gen9ou"

    init(speciesId: String) {
        self.speciesId = speciesId
        let id = speciesId
        _matchedSpecies = Query(filter: #Predicate<Species> { $0.id == id })
        _sets = Query(filter: #Predicate<CompetitiveSet> { $0.speciesId == id })
        _usage = Query(filter: #Predicate<UsageStat> { $0.speciesId == id })
    }

    private var species: Species? { matchedSpecies.first }
    private var availableFormats: [String] {
        Array(Set(sets.map(\.format) + usage.map(\.format))).sorted()
    }
    private var setsForFormat: [CompetitiveSet] { sets.filter { $0.format == selectedFormat } }
    private var usageForFormat: UsageStat? { usage.first { $0.format == selectedFormat } }

    private var speciesById: [String: Species] {
        Dictionary(uniqueKeysWithValues: allSpecies.map { ($0.id, $0) })
    }

    var body: some View {
        Group {
            if let species {
                content(for: species)
            } else {
                ContentUnavailableView("Not Found", systemImage: "questionmark.circle")
            }
        }
        .navigationTitle(species?.name ?? "")
        .onAppear {
            if !availableFormats.contains(selectedFormat), let first = availableFormats.first {
                selectedFormat = first
            }
        }
    }

    @ViewBuilder
    private func content(for species: Species) -> some View {
        List {
            Section {
                HStack {
                    TypeBadge(type: species.primaryType)
                    if let secondary = species.secondaryType {
                        TypeBadge(type: secondary)
                    }
                }
            }

            Section("Base Stats") {
                StatBar(label: "HP", value: species.hp)
                StatBar(label: "Atk", value: species.attack)
                StatBar(label: "Def", value: species.defense)
                StatBar(label: "SpA", value: species.specialAttack)
                StatBar(label: "SpD", value: species.specialDefense)
                StatBar(label: "Spe", value: species.speed)
            }

            Section("Abilities") {
                ForEach(species.abilities, id: \.self) { ability in
                    Text(ability)
                }
            }

            if !availableFormats.isEmpty {
                Section {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(availableFormats, id: \.self) { format in
                            Text(formatLabel(format)).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if let usageForFormat {
                    Section("Usage") {
                        Text("\(usageForFormat.usagePercent, specifier: "%.2f")% of teams")
                    }
                }

                if !setsForFormat.isEmpty {
                    Section("Common Sets") {
                        ForEach(setsForFormat) { set in
                            CompetitiveSetRow(set: set)
                        }
                    }
                }

                if let usageForFormat, !usageForFormat.topTeammates.isEmpty {
                    Section("Common Teammates") {
                        ForEach(usageForFormat.topTeammates, id: \.self) { id in
                            Text(speciesById[id]?.name ?? id)
                        }
                    }
                }

                if let usageForFormat, !usageForFormat.topThreats.isEmpty {
                    Section("Common Threats") {
                        ForEach(usageForFormat.topThreats, id: \.self) { id in
                            Text(speciesById[id]?.name ?? id)
                        }
                    }
                }
            } else {
                Section {
                    Text("No competitive data available for this species in gen9ou or gen9vgc.")
                        .foregroundStyle(.secondary)
                }
            }
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

private struct CompetitiveSetRow: View {
    let set: CompetitiveSet

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(set.setName).font(.headline)
            if let ability = set.ability {
                Text("Ability: \(ability)").font(.caption)
            }
            if let item = set.item {
                Text("Item: \(item)").font(.caption)
            }
            if let nature = set.nature {
                Text("Nature: \(nature)").font(.caption)
            }
            Text(set.moves.joined(separator: " / ")).font(.caption)
        }
        .padding(.vertical, 2)
    }
}
