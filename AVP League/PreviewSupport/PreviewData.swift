import Foundation

enum PreviewData {
    static let season = Season(year: 2026)
    static let team = AVPTeam.allTeams[0]
    static let match = LeagueSampleData.matches(for: 2026).first!
    static let standing = StandingsCalculator.standings(for: LeagueSampleData.matches(for: 2026)).first!
    static let profile = LeagueSampleData.teamProfiles(for: 2026).first { $0.teamID == team.id }!
}
