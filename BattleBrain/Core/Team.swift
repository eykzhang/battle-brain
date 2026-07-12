import Foundation
import SwiftData

@Model
final class Team {
    @Attribute(.unique) var id: UUID
    var name: String
    var format: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \TeamMember.team)
    var members: [TeamMember] = []

    init(id: UUID = UUID(), name: String, format: String, createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.format = format
        self.createdAt = createdAt
    }
}
