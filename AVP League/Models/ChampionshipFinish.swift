import Foundation

struct ChampionshipFinish: Identifiable, Hashable, Codable {
    let place: Int
    let teamID: String

    var id: Int { place }

    var team: AVPTeam { AVPTeam.team(for: teamID) }

    var label: String {
        switch place {
        case 1: "Champions"
        case 2: "2nd Place"
        case 3: "3rd Place"
        case 4: "4th Place"
        default: "\(place)th Place"
        }
    }
}
