import Foundation

/// Pure EV cap validation (Showdown/in-game rules): 252 max per stat, 508 max
/// total across all six. No SwiftUI/SwiftData dependency — trivial to unit test.
enum EVAllocation {
    static let perStatCap = 252
    static let totalCap = 508

    /// Clamps a proposed value for one stat so it respects both caps, given
    /// the current total already allocated to the *other* five stats.
    static func clamp(_ proposedValue: Int, otherStatsTotal: Int) -> Int {
        let perStatClamped = min(max(proposedValue, 0), perStatCap)
        return min(perStatClamped, max(0, totalCap - otherStatsTotal))
    }
}
