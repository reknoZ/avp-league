import Foundation

struct AVPTeam: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let shortName: String
    let city: String

    var displayName: String { name }
}

extension AVPTeam {
    static let allTeams: [AVPTeam] = [
        AVPTeam(id: "nyn", name: "New York Nitro", shortName: "NYN", city: "New York, NY"),
        AVPTeam(id: "bb", name: "Brooklyn Blaze", shortName: "BB", city: "Brooklyn, NY"),
        AVPTeam(id: "lal", name: "LA Launch", shortName: "LAL", city: "Los Angeles, CA"),
        AVPTeam(id: "sds", name: "San Diego Smash", shortName: "SDS", city: "San Diego, CA"),
        AVPTeam(id: "pbp", name: "Palm Beach Passion", shortName: "PBP", city: "Palm Beach, FL"),
        AVPTeam(id: "mm", name: "Miami Mayhem", shortName: "MM", city: "Miami, FL"),
        AVPTeam(id: "aa", name: "Austin Aces", shortName: "AA", city: "Austin, TX"),
        AVPTeam(id: "dd", name: "Dallas Dream", shortName: "DD", city: "Dallas, TX"),
    ]

    static func team(for id: String) -> AVPTeam {
        allTeams.first { $0.id == id } ?? allTeams[0]
    }
}
