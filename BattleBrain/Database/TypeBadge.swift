import SwiftUI

struct TypeBadge: View {
    let type: String

    var body: some View {
        Text(type)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Self.color(for: type), in: Capsule())
    }

    static func color(for type: String) -> Color {
        switch type.lowercased() {
        case "normal": return Color(red: 0.66, green: 0.66, blue: 0.47)
        case "fire": return Color(red: 0.93, green: 0.51, blue: 0.19)
        case "water": return Color(red: 0.39, green: 0.56, blue: 0.93)
        case "electric": return Color(red: 0.97, green: 0.82, blue: 0.19)
        case "grass": return Color(red: 0.48, green: 0.78, blue: 0.30)
        case "ice": return Color(red: 0.59, green: 0.85, blue: 0.85)
        case "fighting": return Color(red: 0.76, green: 0.18, blue: 0.16)
        case "poison": return Color(red: 0.64, green: 0.24, blue: 0.64)
        case "ground": return Color(red: 0.88, green: 0.75, blue: 0.41)
        case "flying": return Color(red: 0.66, green: 0.56, blue: 0.95)
        case "psychic": return Color(red: 0.98, green: 0.33, blue: 0.53)
        case "bug": return Color(red: 0.65, green: 0.73, blue: 0.10)
        case "rock": return Color(red: 0.71, green: 0.63, blue: 0.22)
        case "ghost": return Color(red: 0.44, green: 0.34, blue: 0.60)
        case "dragon": return Color(red: 0.44, green: 0.21, blue: 0.98)
        case "dark": return Color(red: 0.44, green: 0.35, blue: 0.28)
        case "steel": return Color(red: 0.72, green: 0.72, blue: 0.82)
        case "fairy": return Color(red: 0.93, green: 0.60, blue: 0.68)
        default: return .gray
        }
    }
}

#Preview {
    HStack {
        TypeBadge(type: "Fire")
        TypeBadge(type: "Flying")
    }
}
