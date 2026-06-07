import Foundation

@MainActor
@Observable
final class LeagueDataService {
    static let shared = LeagueDataService()

    private(set) var isLoadingLiveScores = false
    private(set) var lastLiveScoreUpdate: Date?
    private(set) var liveScoreError: String?
    private(set) var isUsingLiveData = false

    private(set) var season2026Matches: [LeagueMatch]

    private var autoRefreshTask: Task<Void, Never>?

    private init() {
        let schedule = Self.scheduleOnlyMatches(for: 2026)
        if let cached = MatchResultsCache.load(seasonYear: 2026) {
            season2026Matches = MatchResultsCache.merge(cached.matches, into: schedule)
            lastLiveScoreUpdate = cached.savedAt
            isUsingLiveData = true
        } else {
            season2026Matches = schedule
        }
    }

    func startAutoRefresh(interval: TimeInterval = 30) {
        autoRefreshTask?.cancel()
        autoRefreshTask = Task {
            while !Task.isCancelled {
                await refreshLiveScores()
                try? await Task.sleep(for: .seconds(interval))
            }
        }
    }

    func stopAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = nil
    }

    func refreshLiveScores() async {
        guard !isLoadingLiveScores else { return }

        isLoadingLiveScores = true
        liveScoreError = nil
        defer { isLoadingLiveScores = false }

        do {
            let apiMatches = try await AVPLeagueAPI.fetchMatches()
            let sampleMatches = Self.scheduleOnlyMatches(for: 2026)
            season2026Matches = LiveScoreMapper.synchronizedMatches(
                sampleMatches: sampleMatches,
                apiMatches: apiMatches
            )
            MatchResultsCache.save(season2026Matches, seasonYear: 2026)
            isUsingLiveData = true
            lastLiveScoreUpdate = Date()
        } catch {
            liveScoreError = error.localizedDescription
            if MatchResultsCache.load(seasonYear: 2026) != nil {
                isUsingLiveData = true
            } else {
                isUsingLiveData = false
            }
        }
    }

    private static func scheduleOnlyMatches(for year: Int) -> [LeagueMatch] {
        LeagueSampleData.matches(for: year).map { match in
            LeagueMatch(
                id: match.id,
                seasonYear: match.seasonYear,
                weekNumber: match.weekNumber,
                date: match.date,
                homeTeamID: match.homeTeamID,
                awayTeamID: match.awayTeamID,
                venue: match.venue,
                division: match.division,
                status: .upcoming,
                result: nil
            )
        }
        .sorted { $0.date < $1.date }
    }

    func matches(for season: Season) -> [LeagueMatch] {
        if season.year == 2026 {
            return season2026Matches
        }

        return LeagueSampleData.matches(for: season.year)
            .sorted { $0.date < $1.date }
    }

    func teamProfiles(for season: Season) -> [TeamSeasonProfile] {
        LeagueSampleData.teamProfiles(for: season.year)
            .sorted { $0.team.name < $1.team.name }
    }

    func profile(for team: AVPTeam, season: Season) -> TeamSeasonProfile? {
        teamProfiles(for: season).first { $0.teamID == team.id }
    }

    func standings(for season: Season, category: StandingsCategory = .city) -> [TeamStanding] {
        let seasonMatches = matches(for: season)
        let relevantMatches = category == .city
            ? seasonMatches.inPhase(.regularSeason)
            : seasonMatches
        return StandingsCalculator.standings(for: relevantMatches, category: category)
    }

    func championshipResults(for season: Season) -> [ChampionshipFinish] {
        HistoricalMatchData.championshipResults(for: season.year) ?? []
    }

    func playoffMatches(for season: Season) -> [LeagueMatch] {
        matches(for: season).inPhase(.playoffs)
    }

    func matches(for team: AVPTeam, season: Season) -> [LeagueMatch] {
        matches(for: season).filter { $0.homeTeamID == team.id || $0.awayTeamID == team.id }
    }
}
