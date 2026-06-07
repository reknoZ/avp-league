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

    var gamesPlayed: Int { genderMatchWins + genderMatchLosses }

    var winPercentage: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(genderMatchWins) / Double(gamesPlayed)
    }

    var setDifferential: Int { setsWon - setsLost }

    var setDifferentialDisplay: String {
        let diff = setDifferential
        return diff >= 0 ? "+\(diff)" : "\(diff)"
    }
}
