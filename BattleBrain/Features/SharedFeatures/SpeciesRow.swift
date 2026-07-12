import SwiftUI

/// The visual content of a species row (name + type badges), shared between
/// the Database list (wrapped in a NavigationLink) and species pickers
/// (wrapped in a selection Button) — the interaction differs, the layout doesn't.
struct SpeciesRow: View {
    let species: Species

    var body: some View {
        HStack {
            Text(species.name)
            Spacer()
            TypeBadge(type: species.primaryType)
            if let secondary = species.secondaryType {
                TypeBadge(type: secondary)
            }
        }
    }
}
