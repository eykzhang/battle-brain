import SwiftUI
import SwiftData

struct SpeciesPickerView: View {
    let onSelect: (Species) -> Void

    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Species.name) private var allSpecies: [Species]
    @State private var searchText = ""

    private var filteredSpecies: [Species] {
        guard !searchText.isEmpty else { return allSpecies }
        return allSpecies.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredSpecies) { species in
                Button {
                    onSelect(species)
                    dismiss()
                } label: {
                    SpeciesRow(species: species)
                }
                .buttonStyle(.plain)
            }
            .searchable(text: $searchText, prompt: "Search Pokémon")
            .navigationTitle("Choose Species")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
