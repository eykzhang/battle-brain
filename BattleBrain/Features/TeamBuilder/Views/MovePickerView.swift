import SwiftUI
import SwiftData

struct MovePickerView: View {
    let allowedMoveIds: [String]
    let onSelect: (Move) -> Void

    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Move.name) private var allMoves: [Move]
    @State private var searchText = ""

    private var pickableMoves: [Move] {
        let allowed = Set(allowedMoveIds)
        let moves = allMoves.filter { allowed.contains($0.id) }
        guard !searchText.isEmpty else { return moves }
        return moves.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(pickableMoves) { move in
                Button {
                    onSelect(move)
                    dismiss()
                } label: {
                    MoveRow(move: move)
                }
                .buttonStyle(.plain)
            }
            .searchable(text: $searchText, prompt: "Search Moves")
            .navigationTitle("Choose Move")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

private struct MoveRow: View {
    let move: Move

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(move.name)
                Text(move.category + (move.power.map { " · \($0) power" } ?? ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            TypeBadge(type: move.type)
        }
    }
}
