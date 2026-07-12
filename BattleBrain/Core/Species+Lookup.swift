import Foundation

extension Array where Element == Species {
    /// Keyed by `Species.id`, for resolving a stored `speciesId` back to its record.
    var byId: [String: Species] {
        Dictionary(uniqueKeysWithValues: map { ($0.id, $0) })
    }

    /// Keyed by lowercased `Species.name`, for resolving user-typed/imported names.
    var byLowercasedName: [String: Species] {
        Dictionary(uniqueKeysWithValues: map { ($0.name.lowercased(), $0) })
    }
}
