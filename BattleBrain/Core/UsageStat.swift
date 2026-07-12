import Foundation
import SwiftData

@Model
final class UsageStat {
    @Attribute(.unique) var id: String
    var format: String
    var speciesId: String
    var usagePercent: Double
    var topTeammates: [String]
    var topThreats: [String]

    init(
        id: String,
        format: String,
        speciesId: String,
        usagePercent: Double,
        topTeammates: [String],
        topThreats: [String]
    ) {
        self.id = id
        self.format = format
        self.speciesId = speciesId
        self.usagePercent = usagePercent
        self.topTeammates = topTeammates
        self.topThreats = topThreats
    }
}
