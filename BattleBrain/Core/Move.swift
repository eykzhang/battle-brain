import Foundation
import SwiftData

@Model
final class Move {
    @Attribute(.unique) var id: String
    var name: String
    var type: String
    var category: String
    var power: Int?
    var accuracy: Int?
    var pp: Int

    init(id: String, name: String, type: String, category: String, power: Int?, accuracy: Int?, pp: Int) {
        self.id = id
        self.name = name
        self.type = type
        self.category = category
        self.power = power
        self.accuracy = accuracy
        self.pp = pp
    }
}
