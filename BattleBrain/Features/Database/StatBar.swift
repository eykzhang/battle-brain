import SwiftUI

enum StatKey: String {
    case hp = "HP"
    case attack = "Atk"
    case defense = "Def"
    case specialAttack = "SpA"
    case specialDefense = "SpD"
    case speed = "Spe"

    var color: Color {
        switch self {
        case .hp: return Color(red: 0.94, green: 0.30, blue: 0.26)
        case .attack: return Color(red: 0.95, green: 0.55, blue: 0.22)
        case .defense: return Color(red: 0.95, green: 0.82, blue: 0.26)
        case .specialAttack: return Color(red: 0.40, green: 0.56, blue: 0.93)
        case .specialDefense: return Color(red: 0.45, green: 0.78, blue: 0.35)
        case .speed: return Color(red: 0.96, green: 0.45, blue: 0.64)
        }
    }
}

struct StatBar: View {
    static let displayMax: Double = 255

    let stat: StatKey
    let value: Int

    var body: some View {
        HStack {
            Text(stat.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .leading)
            Text("\(value)")
                .font(.caption.monospacedDigit())
                .frame(width: 28, alignment: .trailing)
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 3)
                    .fill(stat.color)
                    .frame(width: geometry.size.width * min(Double(value) / Self.displayMax, 1.0))
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    VStack {
        StatBar(stat: .hp, value: 100)
        StatBar(stat: .attack, value: 130)
        StatBar(stat: .speed, value: 45)
    }
    .padding()
}
