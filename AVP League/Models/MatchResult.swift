import Foundation

enum GenderDivision: String, Codable, CaseIterable {
    case men
    case women

    var label: String {
        switch self {
        case .men: "Men's"
        case .women: "Women's"
        }
    }

    var shortLabel: String {
        switch self {
        case .men: "M"
        case .women: "F"
        }
    }
}

struct SetScore: Codable, Hashable {
    let homePoints: Int
    let awayPoints: Int
}

struct SideMatchResult: Codable, Hashable {
    let division: GenderDivision
    let sets: [SetScore]

    var homeSetsWon: Int {
        sets.filter { $0.homePoints > $0.awayPoints }.count
    }

    var awaySetsWon: Int {
        sets.filter { $0.awayPoints > $0.homePoints }.count
    }

    var isComplete: Bool {
        homeSetsWon >= 2 || awaySetsWon >= 2
    }

    var scoreSummary: String {
        "\(homeSetsWon)-\(awaySetsWon)"
    }
}
