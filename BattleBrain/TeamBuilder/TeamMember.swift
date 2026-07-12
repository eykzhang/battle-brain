import Foundation
import SwiftData

@Model
final class TeamMember {
    @Attribute(.unique) var id: UUID
    var speciesId: String
    var nickname: String?
    var level: Int
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

    var team: Team?

    init(
        id: UUID = UUID(),
        speciesId: String,
        nickname: String? = nil,
        level: Int = 100,
        moves: [String] = [],
        ability: String? = nil,
        item: String? = nil,
        nature: String? = nil,
        hpEV: Int = 0,
        attackEV: Int = 0,
        defenseEV: Int = 0,
        specialAttackEV: Int = 0,
        specialDefenseEV: Int = 0,
        speedEV: Int = 0,
        hpIV: Int = 31,
        attackIV: Int = 31,
        defenseIV: Int = 31,
        specialAttackIV: Int = 31,
        specialDefenseIV: Int = 31,
        speedIV: Int = 31
    ) {
        self.id = id
        self.speciesId = speciesId
        self.nickname = nickname
        self.level = level
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
    }
}
