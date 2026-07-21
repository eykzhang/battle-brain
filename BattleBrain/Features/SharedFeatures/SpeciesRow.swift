import SwiftUI

struct SpeciesRow: View {
    let species: Species

    var body: some View {
        HStack {
            Text(species.name)
            Spacer()
            Text("\(species.bst)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            TypeBadge(type: species.primaryType)
            if let secondary = species.secondaryType {
                TypeBadge(type: secondary)
            }
        }
    }
}
