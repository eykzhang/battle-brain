import Foundation
import SwiftData

/// Decodes the bundled `dataset.json` (produced by `Scripts/bake_dataset.py`)
/// and seeds SwiftData with it on first launch. A later AWS `/dataset` fetch
/// (not yet implemented) will refresh this same store over the network.
enum DatasetBootstrapper {
    struct DatasetFile: Decodable {
        let version: String
        let species: [SpeciesDTO]
        let sets: [CompetitiveSetDTO]
        let usage: [UsageStatDTO]
    }

    struct SpeciesDTO: Decodable {
        let id: String
        let name: String
        let primaryType: String
        let secondaryType: String?
        let hp: Int
        let attack: Int
        let defense: Int
        let specialAttack: Int
        let specialDefense: Int
        let speed: Int
        let abilities: [String]
    }

    struct CompetitiveSetDTO: Decodable {
        let id: String
        let format: String
        let speciesId: String
        let setName: String
        let moves: [String]
        let ability: String?
        let item: String?
        let nature: String?
        let hpEV: Int
        let attackEV: Int
        let defenseEV: Int
        let specialAttackEV: Int
        let specialDefenseEV: Int
        let speedEV: Int
        let hpIV: Int
        let attackIV: Int
        let defenseIV: Int
        let specialAttackIV: Int
        let specialDefenseIV: Int
        let speedIV: Int
        let teraType: String?
    }

    struct UsageStatDTO: Decodable {
        let id: String
        let format: String
        let speciesId: String
        let usagePercent: Double
    }

    enum BootstrapError: Error {
        case resourceNotFound
    }

    /// No-op if Species data already exists in the store.
    static func bootstrapIfNeeded(context: ModelContext) throws {
        let existingCount = try context.fetchCount(FetchDescriptor<Species>())
        guard existingCount == 0 else { return }

        guard let url = Bundle.main.url(forResource: "dataset", withExtension: "json") else {
            throw BootstrapError.resourceNotFound
        }

        let data = try Data(contentsOf: url)
        let dataset = try JSONDecoder().decode(DatasetFile.self, from: data)

        for dto in dataset.species {
            context.insert(Species(
                id: dto.id,
                name: dto.name,
                primaryType: dto.primaryType,
                secondaryType: dto.secondaryType,
                hp: dto.hp,
                attack: dto.attack,
                defense: dto.defense,
                specialAttack: dto.specialAttack,
                specialDefense: dto.specialDefense,
                speed: dto.speed,
                abilities: dto.abilities
            ))
        }

        for dto in dataset.sets {
            context.insert(CompetitiveSet(
                id: dto.id,
                format: dto.format,
                speciesId: dto.speciesId,
                setName: dto.setName,
                moves: dto.moves,
                ability: dto.ability,
                item: dto.item,
                nature: dto.nature,
                hpEV: dto.hpEV,
                attackEV: dto.attackEV,
                defenseEV: dto.defenseEV,
                specialAttackEV: dto.specialAttackEV,
                specialDefenseEV: dto.specialDefenseEV,
                speedEV: dto.speedEV,
                hpIV: dto.hpIV,
                attackIV: dto.attackIV,
                defenseIV: dto.defenseIV,
                specialAttackIV: dto.specialAttackIV,
                specialDefenseIV: dto.specialDefenseIV,
                speedIV: dto.speedIV,
                teraType: dto.teraType
            ))
        }

        for dto in dataset.usage {
            context.insert(UsageStat(
                id: dto.id,
                format: dto.format,
                speciesId: dto.speciesId,
                usagePercent: dto.usagePercent
            ))
        }

        try context.save()
    }
}
