import Foundation

struct TeamStanding: Identifiable, Hashable {
    let team: AVPTeam
    let rank: Int
    let matchPoints: Int
    let genderMatchWins: Int
    let genderMatchLosses: Int
    let setsWon: Int
    let setsLost: Int

    var id: String { team.id }

    var record: String { "\(genderMatchWins)-\(genderMatchLosses)" }

    var setDifferential: Int { setsWon - setsLost }

    var setDifferentialDisplay: String {
        let diff = setDifferential
        return diff >= 0 ? "+\(diff)" : "\(diff)"
    }
}
