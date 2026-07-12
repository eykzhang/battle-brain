import Foundation
import SwiftData

/// Import/export for Pokémon Showdown's plain-text team format
/// (https://pokepast.es-style export, same format used by the Showdown client
/// itself). Pure, framework-agnostic parsing/serialization — no SwiftData
/// dependency — so it's straightforward to unit test later.
///
/// Documented subset (consistent with the bake script's own simplifications):
/// supports nickname/species/item, ability, level, Tera Type, EVs, nature,
/// IVs, and up to 4 moves. Does not support: gender markers, Shiny, Happiness,
/// Dynamax Level, or alternative-move slashes — none of which this app's
/// TeamMember model tracks.
enum ShowdownTeamFormat {
    struct ParsedMember {
        var speciesName: String
        var nickname: String?
        var item: String?
        var ability: String?
        var level: Int
        var teraType: String?
        var nature: String?
        var evs: [String: Int]
        var ivs: [String: Int]
        var moves: [String]
    }

    private static let evIvLabels = ["HP": "hp", "Atk": "atk", "Def": "def", "SpA": "spa", "SpD": "spd", "Spe": "spe"]

    // MARK: - Conversion

    /// Builds a (not-yet-inserted) `TeamMember` from a parsed entry and the
    /// species it resolved to. Doesn't touch `ModelContext` — insertion and
    /// team-membership wiring stay the caller's responsibility — so this is as
    /// testable as `parse`/`export` themselves.
    static func makeTeamMember(from parsed: ParsedMember, speciesId: String) -> TeamMember {
        TeamMember(
            speciesId: speciesId,
            nickname: parsed.nickname,
            level: parsed.level,
            moves: parsed.moves,
            ability: parsed.ability,
            item: parsed.item,
            nature: parsed.nature,
            teraType: parsed.teraType,
            hpEV: parsed.evs["hp"] ?? 0,
            attackEV: parsed.evs["atk"] ?? 0,
            defenseEV: parsed.evs["def"] ?? 0,
            specialAttackEV: parsed.evs["spa"] ?? 0,
            specialDefenseEV: parsed.evs["spd"] ?? 0,
            speedEV: parsed.evs["spe"] ?? 0,
            hpIV: parsed.ivs["hp"] ?? 31,
            attackIV: parsed.ivs["atk"] ?? 31,
            defenseIV: parsed.ivs["def"] ?? 31,
            specialAttackIV: parsed.ivs["spa"] ?? 31,
            specialDefenseIV: parsed.ivs["spd"] ?? 31,
            speedIV: parsed.ivs["spe"] ?? 31
        )
    }

    // MARK: - Export

    static func export(members: [(species: Species, member: TeamMember)]) -> String {
        members.map(exportMember).joined(separator: "\n\n")
    }

    private static func exportMember(_ pair: (species: Species, member: TeamMember)) -> String {
        let (species, member) = pair
        var lines: [String] = []

        var header = member.nickname.map { "\($0) (\(species.name))" } ?? species.name
        if let item = member.item {
            header += " @ \(item)"
        }
        lines.append(header)

        if let ability = member.ability {
            lines.append("Ability: \(ability)")
        }
        if member.level != 100 {
            lines.append("Level: \(member.level)")
        }
        if let teraType = member.teraType {
            lines.append("Tera Type: \(teraType)")
        }

        let evPairs: [(String, Int)] = [
            ("HP", member.hpEV), ("Atk", member.attackEV), ("Def", member.defenseEV),
            ("SpA", member.specialAttackEV), ("SpD", member.specialDefenseEV), ("Spe", member.speedEV),
        ].filter { $0.1 > 0 }
        if !evPairs.isEmpty {
            lines.append("EVs: " + evPairs.map { "\($0.1) \($0.0)" }.joined(separator: " / "))
        }

        if let nature = member.nature {
            lines.append("\(nature) Nature")
        }

        let ivPairs: [(String, Int)] = [
            ("HP", member.hpIV), ("Atk", member.attackIV), ("Def", member.defenseIV),
            ("SpA", member.specialAttackIV), ("SpD", member.specialDefenseIV), ("Spe", member.speedIV),
        ].filter { $0.1 != 31 }
        if !ivPairs.isEmpty {
            lines.append("IVs: " + ivPairs.map { "\($0.1) \($0.0)" }.joined(separator: " / "))
        }

        for move in member.moves where !move.isEmpty {
            lines.append("- \(move)")
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Import

    static func parse(_ text: String) -> [ParsedMember] {
        let blocks = text
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return blocks.compactMap(parseBlock)
    }

    private static func parseBlock(_ block: String) -> ParsedMember? {
        let lines = block.split(separator: "\n").map(String.init)
        guard let headerLine = lines.first else { return nil }

        var speciesName = headerLine
        var item: String?
        if let range = headerLine.range(of: " @ ") {
            speciesName = String(headerLine[headerLine.startIndex..<range.lowerBound])
            item = String(headerLine[range.upperBound...]).trimmingCharacters(in: .whitespaces)
        }

        var nickname: String?
        if let openParen = speciesName.firstIndex(of: "("), let closeParen = speciesName.lastIndex(of: ")") {
            nickname = String(speciesName[speciesName.startIndex..<openParen]).trimmingCharacters(in: .whitespaces)
            speciesName = String(speciesName[speciesName.index(after: openParen)..<closeParen])
        }
        speciesName = speciesName.trimmingCharacters(in: .whitespaces)

        var ability: String?
        var level = 100
        var teraType: String?
        var nature: String?
        var evs: [String: Int] = [:]
        var ivs: [String: Int] = [:]
        var moves: [String] = []

        for line in lines.dropFirst() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("Ability: ") {
                ability = String(trimmed.dropFirst("Ability: ".count))
            } else if trimmed.hasPrefix("Level: ") {
                level = Int(trimmed.dropFirst("Level: ".count)) ?? 100
            } else if trimmed.hasPrefix("Tera Type: ") {
                teraType = String(trimmed.dropFirst("Tera Type: ".count))
            } else if trimmed.hasPrefix("EVs: ") {
                evs = parseStatLine(String(trimmed.dropFirst("EVs: ".count)))
            } else if trimmed.hasPrefix("IVs: ") {
                ivs = parseStatLine(String(trimmed.dropFirst("IVs: ".count)))
            } else if trimmed.hasSuffix(" Nature") {
                nature = String(trimmed.dropLast(" Nature".count))
            } else if trimmed.hasPrefix("- ") {
                moves.append(String(trimmed.dropFirst(2)))
            }
        }

        return ParsedMember(
            speciesName: speciesName,
            nickname: nickname,
            item: item,
            ability: ability,
            level: level,
            teraType: teraType,
            nature: nature,
            evs: evs,
            ivs: ivs,
            moves: moves
        )
    }

    private static func parseStatLine(_ line: String) -> [String: Int] {
        var result: [String: Int] = [:]
        for token in line.components(separatedBy: " / ") {
            let parts = token.trimmingCharacters(in: .whitespaces).split(separator: " ", maxSplits: 1)
            guard parts.count == 2, let value = Int(parts[0]), let key = evIvLabels[String(parts[1])] else { continue }
            result[key] = value
        }
        return result
    }
}
