import Foundation

/// The 25 natures and their stat modifiers. Static game data (unchanged since
/// Gen III) — not sourced from the bundled dataset or any API.
struct Nature: Identifiable {
    enum Stat: String {
        case attack = "Atk", defense = "Def", specialAttack = "SpA", specialDefense = "SpD", speed = "Spe"
    }

    let name: String
    let boosted: Stat?
    let lowered: Stat?

    var id: String { name }
    var isNeutral: Bool { boosted == nil }

    static let all: [Nature] = [
        Nature(name: "Hardy", boosted: nil, lowered: nil),
        Nature(name: "Docile", boosted: nil, lowered: nil),
        Nature(name: "Serious", boosted: nil, lowered: nil),
        Nature(name: "Bashful", boosted: nil, lowered: nil),
        Nature(name: "Quirky", boosted: nil, lowered: nil),
        Nature(name: "Lonely", boosted: .attack, lowered: .defense),
        Nature(name: "Adamant", boosted: .attack, lowered: .specialAttack),
        Nature(name: "Naughty", boosted: .attack, lowered: .specialDefense),
        Nature(name: "Brave", boosted: .attack, lowered: .speed),
        Nature(name: "Bold", boosted: .defense, lowered: .attack),
        Nature(name: "Impish", boosted: .defense, lowered: .specialAttack),
        Nature(name: "Lax", boosted: .defense, lowered: .specialDefense),
        Nature(name: "Relaxed", boosted: .defense, lowered: .speed),
        Nature(name: "Modest", boosted: .specialAttack, lowered: .attack),
        Nature(name: "Mild", boosted: .specialAttack, lowered: .defense),
        Nature(name: "Quiet", boosted: .specialAttack, lowered: .speed),
        Nature(name: "Rash", boosted: .specialAttack, lowered: .specialDefense),
        Nature(name: "Calm", boosted: .specialDefense, lowered: .attack),
        Nature(name: "Gentle", boosted: .specialDefense, lowered: .defense),
        Nature(name: "Careful", boosted: .specialDefense, lowered: .specialAttack),
        Nature(name: "Sassy", boosted: .specialDefense, lowered: .speed),
        Nature(name: "Timid", boosted: .speed, lowered: .attack),
        Nature(name: "Hasty", boosted: .speed, lowered: .defense),
        Nature(name: "Jolly", boosted: .speed, lowered: .specialAttack),
        Nature(name: "Naive", boosted: .speed, lowered: .specialDefense),
    ]

    static func named(_ name: String) -> Nature? {
        all.first { $0.name == name }
    }
}
