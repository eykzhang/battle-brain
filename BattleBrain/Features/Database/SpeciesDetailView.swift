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

    private var speciesById: [String: Species] { allSpecies.byId }

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

            Section("Base Stats — \(species.bst) BST") {
                StatBar(stat: .hp, value: species.hp)
                StatBar(stat: .attack, value: species.attack)
                StatBar(stat: .defense, value: species.defense)
                StatBar(stat: .specialAttack, value: species.specialAttack)
                StatBar(stat: .specialDefense, value: species.specialDefense)
                StatBar(stat: .speed, value: species.speed)
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
                            if let teammate = speciesById[id] {
                                NavigationLink(value: teammate.id) {
                                    SpeciesRow(species: teammate)
                                }
                            }
                        }
                    }
                }

                if let usageForFormat, !usageForFormat.topThreats.isEmpty {
                    Section("Common Threats") {
                        ForEach(usageForFormat.topThreats, id: \.self) { id in
                            if let threat = speciesById[id] {
                                NavigationLink(value: threat.id) {
                                    SpeciesRow(species: threat)
                                }
                            }
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

    private var evSpread: String {
        let parts: [(Int, String)] = [
            (set.hpEV, "HP"), (set.attackEV, "Atk"), (set.defenseEV, "Def"),
            (set.specialAttackEV, "SpA"), (set.specialDefenseEV, "SpD"), (set.speedEV, "Spe"),
        ]
        return parts.filter { $0.0 > 0 }.map { "\($0.0) \($0.1)" }.joined(separator: " / ")
    }

    private var nonDefaultIVs: String? {
        let parts: [(Int, String)] = [
            (set.hpIV, "HP"), (set.attackIV, "Atk"), (set.defenseIV, "Def"),
            (set.specialAttackIV, "SpA"), (set.specialDefenseIV, "SpD"), (set.speedIV, "Spe"),
        ]
        let changed = parts.filter { $0.0 != 31 }.map { "\($0.0) \($0.1)" }
        return changed.isEmpty ? nil : changed.joined(separator: " / ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(set.setName).font(.headline)
                Spacer()
                if let tera = set.teraType {
                    TypeBadge(type: tera)
                }
            }

            HStack(spacing: 12) {
                if let ability = set.ability {
                    Label(ability, systemImage: "sparkle")
                        .font(.caption)
                }
                if let item = set.item {
                    Label(item, systemImage: "bag")
                        .font(.caption)
                }
                if let nature = set.nature {
                    Label(nature, systemImage: "arrow.up.arrow.down")
                        .font(.caption)
                }
            }
            .foregroundStyle(.secondary)

            Text(set.moves.joined(separator: " / "))
                .font(.caption)

            if !evSpread.isEmpty {
                Text("EVs: \(evSpread)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if let ivs = nonDefaultIVs {
                Text("IVs: \(ivs)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
