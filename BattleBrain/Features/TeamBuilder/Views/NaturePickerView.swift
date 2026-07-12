import SwiftUI

struct NaturePickerView: View {
    let onSelect: (Nature) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(Nature.all) { nature in
                Button {
                    onSelect(nature)
                    dismiss()
                } label: {
                    HStack {
                        Text(nature.name)
                        Spacer()
                        if let boosted = nature.boosted, let lowered = nature.lowered {
                            Text("+\(boosted.rawValue) / -\(lowered.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Neutral")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Choose Nature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
