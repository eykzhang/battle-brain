import SwiftUI
import SwiftData

struct DatabaseListView: View {
    @Query(sort: \Species.name) private var allSpecies: [Species]
    @State private var searchText = ""

    private var filteredSpecies: [Species] {
        guard !searchText.isEmpty else { return allSpecies }
        return allSpecies.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List(filteredSpecies) { species in
            NavigationLink(value: species.id) {
                SpeciesRow(species: species)
            }
        }
        .searchable(text: $searchText, prompt: "Search Pokémon")
        .navigationTitle("Database")
        .navigationDestination(for: String.self) { speciesId in
            SpeciesDetailView(speciesId: speciesId)
        }
    }
}
