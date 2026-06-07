import Foundation

enum HistoricalMatchData {
    private struct Payload: Decodable {
        let seasonYear: Int
        let teams: [StoredTeam]?
        let matches: [StoredMatch]?
        let championshipResults: [ChampionshipFinish]?
    }

    private struct StoredTeam: Decodable {
        let teamID: String
        let mensPair: PlayerPair
        let womensPair: PlayerPair
    }

    private struct StoredMatch: Decodable {
        let id: String
        let seasonYear: Int
        let weekNumber: Int
        let month: Int
        let day: Int
        let hour: Int
        let homeTeamID: String
        let awayTeamID: String
        let venue: String
        let division: String
        let status: String
        let sets: [StoredSet]
    }

    private struct StoredSet: Decodable {
        let homePoints: Int
        let awayPoints: Int
    }

    private static func payload(for year: Int) -> Payload? {
        let url =
            Bundle.main.url(forResource: String(year), withExtension: "json", subdirectory: "HistoricalMatches")
            ?? Bundle.main.url(forResource: String(year), withExtension: "json")

        guard let url else { return nil }

        do {
            let data = try Data(contentsOf: url)
            let payload = try JSONDecoder().decode(Payload.self, from: data)
            guard payload.seasonYear == year else { return nil }
            return payload
        } catch {
            return nil
        }
    }

    static func matches(for year: Int) -> [LeagueMatch]? {
        guard let payload = payload(for: year), let storedMatches = payload.matches else { return nil }
        return storedMatches.map(leagueMatch(from:)).sorted { $0.date < $1.date }
    }

    static func teamProfiles(for year: Int) -> [TeamSeasonProfile]? {
        guard let payload = payload(for: year), let storedTeams = payload.teams else { return nil }
        return storedTeams.map { stored in
            TeamSeasonProfile(
                teamID: stored.teamID,
                seasonYear: year,
                mensPair: stored.mensPair,
                womensPair: stored.womensPair,
                events: []
            )
        }
    }

    static func championshipResults(for year: Int) -> [ChampionshipFinish]? {
        guard let payload = payload(for: year), let results = payload.championshipResults else { return nil }
        return results.sorted { $0.place < $1.place }
    }

    private static func leagueMatch(from stored: StoredMatch) -> LeagueMatch {
        let division: GenderDivision = stored.division == "women" ? .women : .men
        let status: MatchStatus = stored.status == "completed" ? .completed : .upcoming
        let result = SideMatchResult(
            division: division,
            sets: stored.sets.map { SetScore(homePoints: $0.homePoints, awayPoints: $0.awayPoints) }
        )

        var components = DateComponents()
        components.year = stored.seasonYear
        components.month = stored.month
        components.day = stored.day
        components.hour = stored.hour
        components.minute = 0
        components.timeZone = VenueTimeZone.timeZone(for: stored.venue)

        return LeagueMatch(
            id: stored.id,
            seasonYear: stored.seasonYear,
            weekNumber: stored.weekNumber,
            date: Calendar.current.date(from: components) ?? Date(),
            homeTeamID: stored.homeTeamID,
            awayTeamID: stored.awayTeamID,
            venue: stored.venue,
            division: division,
            status: status,
            result: result
        )
    }
}
