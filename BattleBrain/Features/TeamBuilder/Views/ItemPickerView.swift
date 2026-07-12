import SwiftUI
import SwiftData

/// Item choices come from the union of items seen across bundled competitive
/// sets (`CompetitiveSet.item`) rather than a full PokeAPI item list — Smogon's
/// sample sets are already curated to *competitively relevant held items*,
/// whereas PokeAPI's raw item list includes Poké Balls, medicine, key items,
/// etc. that make no sense as a held battle item.
struct ItemPickerView: View {
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @Query private var sets: [CompetitiveSet]
    @State private var searchText = ""

    private var allItems: [String] {
        Array(Set(sets.compactMap(\.item))).sorted()
    }

    private var filteredItems: [String] {
        guard !searchText.isEmpty else { return allItems }
        return allItems.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredItems, id: \.self) { item in
                Button {
                    onSelect(item)
                    dismiss()
                } label: {
                    Text(item)
                }
                .buttonStyle(.plain)
            }
            .searchable(text: $searchText, prompt: "Search Items")
            .navigationTitle("Choose Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
