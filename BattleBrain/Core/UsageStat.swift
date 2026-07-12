import Foundation
import SwiftData

@Model
final class UsageStat {
    @Attribute(.unique) var id: String
    var format: String
    var speciesId: String
    var usagePercent: Double

    init(id: String, format: String, speciesId: String, usagePercent: Double) {
        self.id = id
        self.format = format
        self.speciesId = speciesId
        self.usagePercent = usagePercent
    }
}
