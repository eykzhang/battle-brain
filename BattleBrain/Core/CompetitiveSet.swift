import Foundation
import SwiftData

@Model
final class CompetitiveSet {
    @Attribute(.unique) var id: String
    var format: String
    var speciesId: String
    var setName: String
    var moves: [String]
    var ability: String?
    var item: String?
    var nature: String?
    var hpEV: Int
    var attackEV: Int
    var defenseEV: Int
    var specialAttackEV: Int
    var specialDefenseEV: Int
    var speedEV: Int
    var hpIV: Int
    var attackIV: Int
    var defenseIV: Int
    var specialAttackIV: Int
    var specialDefenseIV: Int
    var speedIV: Int
    var teraType: String?

    init(
        id: String,
        format: String,
        speciesId: String,
        setName: String,
        moves: [String],
        ability: String?,
        item: String?,
        nature: String?,
        hpEV: Int,
        attackEV: Int,
        defenseEV: Int,
        specialAttackEV: Int,
        specialDefenseEV: Int,
        speedEV: Int,
        hpIV: Int,
        attackIV: Int,
        defenseIV: Int,
        specialAttackIV: Int,
        specialDefenseIV: Int,
        speedIV: Int,
        teraType: String?
    ) {
        self.id = id
        self.format = format
        self.speciesId = speciesId
        self.setName = setName
        self.moves = moves
        self.ability = ability
        self.item = item
        self.nature = nature
        self.hpEV = hpEV
        self.attackEV = attackEV
        self.defenseEV = defenseEV
        self.specialAttackEV = specialAttackEV
        self.specialDefenseEV = specialDefenseEV
        self.speedEV = speedEV
        self.hpIV = hpIV
        self.attackIV = attackIV
        self.defenseIV = defenseIV
        self.specialAttackIV = specialAttackIV
        self.specialDefenseIV = specialDefenseIV
        self.speedIV = speedIV
        self.teraType = teraType
    }
}
