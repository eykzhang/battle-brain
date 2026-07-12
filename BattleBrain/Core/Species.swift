import Foundation
import SwiftData

@Model
final class Species {
    @Attribute(.unique) var id: String
    var name: String
    var primaryType: String
    var secondaryType: String?
    var hp: Int
    var attack: Int
    var defense: Int
    var specialAttack: Int
    var specialDefense: Int
    var speed: Int
    var abilities: [String]
    var learnableMoveIds: [String]

    init(
        id: String,
        name: String,
        primaryType: String,
        secondaryType: String?,
        hp: Int,
        attack: Int,
        defense: Int,
        specialAttack: Int,
        specialDefense: Int,
        speed: Int,
        abilities: [String],
        learnableMoveIds: [String]
    ) {
        self.id = id
        self.name = name
        self.primaryType = primaryType
        self.secondaryType = secondaryType
        self.hp = hp
        self.attack = attack
        self.defense = defense
        self.specialAttack = specialAttack
        self.specialDefense = specialDefense
        self.speed = speed
        self.abilities = abilities
        self.learnableMoveIds = learnableMoveIds
    }
}
