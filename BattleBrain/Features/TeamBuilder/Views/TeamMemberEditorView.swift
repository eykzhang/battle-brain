import SwiftUI
import SwiftData

struct TeamMemberEditorView: View {
    @Bindable var member: TeamMember

    @Query private var allSpecies: [Species]
    @Query private var allMoves: [Move]
    @State private var showingSpeciesPicker = false
    @State private var showingItemPicker = false
    @State private var showingNaturePicker = false
    @State private var movePickerSlot: Int?

    private static let types = [
        "Normal", "Fire", "Water", "Electric", "Grass", "Ice", "Fighting", "Poison",
        "Ground", "Flying", "Psychic", "Bug", "Rock", "Ghost", "Dragon", "Dark", "Steel", "Fairy",
    ]

    private var species: Species? {
        allSpecies.first { $0.id == member.speciesId }
    }

    private var movesByName: [String: Move] {
        Dictionary(uniqueKeysWithValues: allMoves.map { ($0.name, $0) })
    }

    private var evTotal: Int {
        member.hpEV + member.attackEV + member.defenseEV
            + member.specialAttackEV + member.specialDefenseEV + member.speedEV
    }

    var body: some View {
        Form {
            Section {
                Button {
                    showingSpeciesPicker = true
                } label: {
                    HStack {
                        Text("Species")
                        Spacer()
                        Text(species?.name ?? "Choose Species")
                            .foregroundStyle(species == nil ? .secondary : .primary)
                    }
                }
                TextField("Nickname (optional)", text: Binding(
                    get: { member.nickname ?? "" },
                    set: { member.nickname = $0.isEmpty ? nil : $0 }
                ))
                Stepper("Level: \(member.level)", value: $member.level, in: 1...100)
            }

            if let species {
                Section("Ability") {
                    Picker("Ability", selection: Binding(
                        get: { member.ability ?? species.abilities.first ?? "" },
                        set: { member.ability = $0 }
                    )) {
                        ForEach(species.abilities, id: \.self) { ability in
                            Text(ability).tag(ability)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Moves") {
                    ForEach(0..<4, id: \.self) { slot in
                        Button {
                            movePickerSlot = slot
                        } label: {
                            HStack {
                                Text("Move \(slot + 1)")
                                Spacer()
                                if let name = moveName(at: slot) {
                                    if let move = movesByName[name] {
                                        TypeBadge(type: move.type)
                                    }
                                    Text(name)
                                } else {
                                    Text("—")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            } else {
                Section {
                    Text("Choose a species to pick its ability and moves.")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Item & Nature") {
                Button {
                    showingItemPicker = true
                } label: {
                    HStack {
                        Text("Item")
                        Spacer()
                        Text(member.item ?? "None").foregroundStyle(member.item == nil ? .secondary : .primary)
                    }
                }
                Button {
                    showingNaturePicker = true
                } label: {
                    HStack {
                        Text("Nature")
                        Spacer()
                        Text(member.nature ?? "Choose Nature")
                            .foregroundStyle(member.nature == nil ? .secondary : .primary)
                    }
                }
                Picker("Tera Type", selection: Binding(
                    get: { member.teraType ?? species?.primaryType ?? "Normal" },
                    set: { member.teraType = $0 }
                )) {
                    ForEach(Self.types, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
            }

            Section("EVs (\(evTotal)/\(EVAllocation.totalCap))") {
                evStepper("HP", value: $member.hpEV)
                evStepper("Atk", value: $member.attackEV)
                evStepper("Def", value: $member.defenseEV)
                evStepper("SpA", value: $member.specialAttackEV)
                evStepper("SpD", value: $member.specialDefenseEV)
                evStepper("Spe", value: $member.speedEV)
            }

            Section("IVs") {
                ivStepper("HP", value: $member.hpIV)
                ivStepper("Atk", value: $member.attackIV)
                ivStepper("Def", value: $member.defenseIV)
                ivStepper("SpA", value: $member.specialAttackIV)
                ivStepper("SpD", value: $member.specialDefenseIV)
                ivStepper("Spe", value: $member.speedIV)
            }
        }
        .navigationTitle(member.nickname ?? species?.name ?? "New Pokémon")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSpeciesPicker) {
            SpeciesPickerView { selected in
                member.speciesId = selected.id
                member.moves = []
                member.ability = nil
            }
        }
        .sheet(isPresented: $showingItemPicker) {
            ItemPickerView { member.item = $0 }
        }
        .sheet(isPresented: $showingNaturePicker) {
            NaturePickerView { member.nature = $0.name }
        }
        .sheet(item: Binding(
            get: { movePickerSlot.map { MoveSlot(index: $0) } },
            set: { movePickerSlot = $0?.index }
        )) { slot in
            MovePickerView(allowedMoveIds: species?.learnableMoveIds ?? []) { move in
                setMove(move.name, at: slot.index)
            }
        }
    }

    private struct MoveSlot: Identifiable {
        let index: Int
        var id: Int { index }
    }

    private func moveName(at slot: Int) -> String? {
        slot < member.moves.count ? member.moves[slot] : nil
    }

    private func setMove(_ name: String, at slot: Int) {
        var moves = member.moves
        while moves.count <= slot {
            moves.append("")
        }
        moves[slot] = name
        member.moves = moves
    }

    @ViewBuilder
    private func evStepper(_ label: String, value: Binding<Int>) -> some View {
        Stepper(value: value, in: 0...EVAllocation.perStatCap, step: 4) {
            HStack {
                Text(label)
                Spacer()
                Text("\(value.wrappedValue)")
            }
        }
        .onChange(of: value.wrappedValue) { _, newValue in
            let otherStatsTotal = evTotal - newValue
            value.wrappedValue = EVAllocation.clamp(newValue, otherStatsTotal: otherStatsTotal)
        }
    }

    @ViewBuilder
    private func ivStepper(_ label: String, value: Binding<Int>) -> some View {
        Stepper(value: value, in: 0...31) {
            HStack {
                Text(label)
                Spacer()
                Text("\(value.wrappedValue)")
            }
        }
    }
}
