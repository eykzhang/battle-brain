import SwiftUI
import SwiftData
import UIKit

struct TeamEditorView: View {
    @Bindable var team: Team

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Species.name) private var allSpecies: [Species]

    @State private var showingExport = false
    @State private var showingImport = false
    @State private var exportText = ""
    @State private var importText = ""
    @State private var importSummary: String?

    private static let formats = ["gen9ou", "gen9vgc"]
    private static let maxTeamSize = 6

    private var speciesById: [String: Species] { allSpecies.byId }

    var body: some View {
        Form {
            Section {
                TextField("Team Name", text: $team.name)
                Picker("Format", selection: $team.format) {
                    ForEach(Self.formats, id: \.self) { format in
                        Text(formatLabel(format)).tag(format)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Roster (\(team.members.count)/\(Self.maxTeamSize))") {
                ForEach(team.members) { member in
                    NavigationLink {
                        TeamMemberEditorView(member: member)
                    } label: {
                        memberRow(member)
                    }
                }
                .onDelete(perform: deleteMembers)

                if team.members.count < Self.maxTeamSize {
                    Button {
                        addMember()
                    } label: {
                        Label("Add Pokémon", systemImage: "plus.circle")
                    }
                }
            }
        }
        .navigationTitle(team.name.isEmpty ? "New Team" : team.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Export as Text") {
                        exportText = ShowdownTeamFormat.export(members: exportPairs())
                        showingExport = true
                    }
                    Button("Import from Text") {
                        importText = ""
                        showingImport = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingExport) {
            exportSheet
        }
        .sheet(isPresented: $showingImport) {
            importSheet
        }
        .alert("Import Complete", isPresented: Binding(
            get: { importSummary != nil },
            set: { if !$0 { importSummary = nil } }
        )) {
            Button("OK") { importSummary = nil }
        } message: {
            Text(importSummary ?? "")
        }
    }

    @ViewBuilder
    private func memberRow(_ member: TeamMember) -> some View {
        if let species = speciesById[member.speciesId] {
            VStack(alignment: .leading, spacing: 4) {
                SpeciesRow(species: species)
                HStack(spacing: 8) {
                    if let item = member.item {
                        Label(item, systemImage: "bag")
                    }
                    if let nature = member.nature {
                        Label(nature, systemImage: "arrow.up.arrow.down")
                    }
                    let moveCount = member.moves.filter { !$0.isEmpty }.count
                    if moveCount > 0 {
                        Label("\(moveCount)/4 moves", systemImage: "burst")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        } else {
            Text("Choose Species")
                .foregroundStyle(.secondary)
        }
    }

    private var exportSheet: some View {
        NavigationStack {
            ScrollView {
                Text(exportText)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle("Export Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Copy") {
                        UIPasteboard.general.string = exportText
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showingExport = false }
                }
            }
        }
    }

    private var importSheet: some View {
        NavigationStack {
            TextEditor(text: $importText)
                .font(.system(.body, design: .monospaced))
                .padding()
                .navigationTitle("Import Team")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Import") { performImport() }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingImport = false }
                    }
                }
        }
    }

    private func exportPairs() -> [(species: Species, member: TeamMember)] {
        team.members.compactMap { member in
            speciesById[member.speciesId].map { (species: $0, member: member) }
        }
    }

    private func performImport() {
        let parsed = ShowdownTeamFormat.parse(importText)
        let speciesByName = allSpecies.byLowercasedName

        var imported = 0
        var skipped = 0
        for entry in parsed {
            guard team.members.count < Self.maxTeamSize,
                  let species = speciesByName[entry.speciesName.lowercased()] else {
                skipped += 1
                continue
            }
            let member = ShowdownTeamFormat.makeTeamMember(from: entry, speciesId: species.id)
            member.team = team
            modelContext.insert(member)
            team.members.append(member)
            imported += 1
        }

        showingImport = false
        importSummary = "Imported \(imported) Pokémon" + (skipped > 0 ? ", skipped \(skipped) (unrecognized species or team full)" : ".")
    }

    private func addMember() {
        let member = TeamMember(speciesId: "")
        member.team = team
        modelContext.insert(member)
        team.members.append(member)
    }

    private func deleteMembers(at offsets: IndexSet) {
        for index in offsets {
            let member = team.members[index]
            modelContext.delete(member)
        }
        team.members.remove(atOffsets: offsets)
    }

    private func formatLabel(_ format: String) -> String {
        switch format {
        case "gen9ou": return "OU"
        case "gen9vgc": return "VGC"
        default: return format
        }
    }
}
