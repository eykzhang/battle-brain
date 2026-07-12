import SwiftUI

/// A single base-stat row with a proportional bar. Pokémon base stats are
/// conventionally capped for display purposes at 255 (the highest any
/// species reaches, e.g. Blissey's HP).
struct StatBar: View {
    static let displayMax: Double = 255

    let label: String
    let value: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .leading)
            Text("\(value)")
                .font(.caption.monospacedDigit())
                .frame(width: 28, alignment: .trailing)
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 3)
                    .fill(barColor)
                    .frame(width: geometry.size.width * min(Double(value) / Self.displayMax, 1.0))
            }
            .frame(height: 8)
        }
    }

    private var barColor: Color {
        switch value {
        case ..<50: return .red
        case 50..<90: return .orange
        case 90..<120: return .yellow
        default: return .green
        }
    }
}

#Preview {
    VStack {
        StatBar(label: "HP", value: 100)
        StatBar(label: "Atk", value: 130)
        StatBar(label: "Spe", value: 45)
    }
    .padding()
}
