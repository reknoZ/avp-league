import Foundation

enum SeasonPhase: String, CaseIterable, Identifiable {
    case regularSeason
    case playoffs

    var id: String { rawValue }

    var title: String {
        switch self {
        case .regularSeason: "Regular Season"
        case .playoffs: "Championship"
        }
    }
}

enum SeasonStructure {
    static let regularSeasonWeekCount = 8
    static let playoffWeekNumber = 9
    static let playoffTeamCount = 4

    static func phase(for weekNumber: Int) -> SeasonPhase {
        weekNumber <= regularSeasonWeekCount ? .regularSeason : .playoffs
    }
}

extension LeagueMatch {
    var phase: SeasonPhase {
        SeasonStructure.phase(for: weekNumber)
    }
}

extension Array where Element == LeagueMatch {
    func inPhase(_ phase: SeasonPhase) -> [LeagueMatch] {
        filter { $0.phase == phase }
    }
}
