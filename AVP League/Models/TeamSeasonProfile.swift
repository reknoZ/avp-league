import Foundation

struct PlayerPair: Hashable, Codable {
    let player1: String
    let player2: String

    var display: String { "\(player1) / \(player2)" }
}

struct TeamSeasonProfile: Identifiable, Hashable {
    let teamID: String
    let seasonYear: Int
    let mensPair: PlayerPair
    let womensPair: PlayerPair
    let events: [String]

    var id: String { "\(teamID)-\(seasonYear)" }

    var team: AVPTeam { AVPTeam.team(for: teamID) }
}
