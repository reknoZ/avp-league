import Foundation

enum LiveScoreMapper {
    private static let teamIDsByName: [String: String] = [
        "LA Launch": "lal",
        "San Diego Smash": "sds",
        "New York Nitro": "nyn",
        "Brooklyn Blaze": "bb",
        "Palm Beach Passion": "pbp",
        "Miami Mayhem": "mm",
        "Austin Aces": "aa",
        "Dallas Dream": "dd",
    ]

    private static let scheduleDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let scheduleDateFormatterNoFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static func synchronizedMatches(
        sampleMatches: [LeagueMatch],
        apiMatches: [AVPLeagueAPI.APIMatch]
    ) -> [LeagueMatch] {
        let apiByWeek = Dictionary(grouping: apiMatches) { weekNumber(from: $0.competitionCode) ?? 0 }
        let sampleByWeek = Dictionary(grouping: sampleMatches, by: \.weekNumber)

        return sampleMatches.map { sample in
            guard let weekAPIMatches = apiByWeek[sample.weekNumber] else {
                return clearedSampleMatch(sample)
            }
            let sampleIndex = orderedWeekMatches(sampleByWeek[sample.weekNumber] ?? []).firstIndex(of: sample) ?? 0
            let matchNo = sampleIndex + 1

            guard let apiMatch = weekAPIMatches.first(where: { $0.matchNo == matchNo }) else {
                return clearedSampleMatch(sample)
            }

            return updatedMatch(sample, from: apiMatch)
        }
    }

    private static func clearedSampleMatch(_ sample: LeagueMatch) -> LeagueMatch {
        LeagueMatch(
            id: sample.id,
            seasonYear: sample.seasonYear,
            weekNumber: sample.weekNumber,
            date: sample.date,
            homeTeamID: sample.homeTeamID,
            awayTeamID: sample.awayTeamID,
            venue: sample.venue,
            division: sample.division,
            status: .upcoming,
            result: nil
        )
    }

    private static func orderedWeekMatches(_ matches: [LeagueMatch]) -> [LeagueMatch] {
        matches.sorted { $0.date < $1.date }
    }

    private static func updatedMatch(_ sample: LeagueMatch, from apiMatch: AVPLeagueAPI.APIMatch) -> LeagueMatch {
        let homeTeamID = teamIDsByName[apiMatch.teamA?.name ?? ""] ?? sample.homeTeamID
        let awayTeamID = teamIDsByName[apiMatch.teamB?.name ?? ""] ?? sample.awayTeamID
        let division = division(for: apiMatch.teamA?.captain?.gender) ?? sample.division
        let date = parsedDate(from: apiMatch) ?? sample.date
        let venue = venue(from: apiMatch, fallback: sample.venue)
        let status = matchStatus(from: apiMatch)
        let result = scoreResult(
            from: apiMatch,
            division: division,
            status: status,
            homeTeamID: homeTeamID,
            awayTeamID: awayTeamID
        )

        return LeagueMatch(
            id: sample.id,
            seasonYear: sample.seasonYear,
            weekNumber: sample.weekNumber,
            date: date,
            homeTeamID: homeTeamID,
            awayTeamID: awayTeamID,
            venue: venue,
            division: division,
            status: status,
            result: result
        )
    }

    private static func scoreResult(
        from apiMatch: AVPLeagueAPI.APIMatch,
        division: GenderDivision,
        status: MatchStatus,
        homeTeamID: String,
        awayTeamID: String
    ) -> SideMatchResult? {
        guard status == .completed || status == .inProgress else { return nil }
        guard !apiMatch.sets.isEmpty else { return nil }
        return orientedResult(from: apiMatch, division: division, homeTeamID: homeTeamID, awayTeamID: awayTeamID)
    }

    private static func matchStatus(from apiMatch: AVPLeagueAPI.APIMatch) -> MatchStatus {
        switch apiMatch.matchState?.uppercased() {
        case "F":
            return .completed
        case "P", "C":
            return .inProgress
        default:
            return .upcoming
        }
    }

    private static func orientedResult(
        from apiMatch: AVPLeagueAPI.APIMatch,
        division: GenderDivision,
        homeTeamID: String,
        awayTeamID: String
    ) -> SideMatchResult? {
        let rawResult = SideMatchResult(
            division: division,
            sets: apiMatch.sets.map { SetScore(homePoints: $0.a, awayPoints: $0.b) }
        )

        let apiHomeID = teamIDsByName[apiMatch.teamA?.name ?? ""]
        let apiAwayID = teamIDsByName[apiMatch.teamB?.name ?? ""]

        guard let apiHomeID, let apiAwayID else { return rawResult }

        if homeTeamID == apiHomeID, awayTeamID == apiAwayID {
            return rawResult
        }

        if homeTeamID == apiAwayID, awayTeamID == apiHomeID {
            return SideMatchResult(
                division: rawResult.division,
                sets: rawResult.sets.map { SetScore(homePoints: $0.awayPoints, awayPoints: $0.homePoints) }
            )
        }

        return rawResult
    }

    private static func venue(from apiMatch: AVPLeagueAPI.APIMatch, fallback: String) -> String {
        if let court = apiMatch.matchSchedule?.courtName, !court.isEmpty {
            if let competition = competitionVenue(from: apiMatch.competitionName) {
                return "\(court), \(competition)"
            }
            return court
        }
        return competitionVenue(from: apiMatch.competitionName) ?? fallback
    }

    private static func competitionVenue(from competitionName: String) -> String? {
        guard let dashIndex = competitionName.firstIndex(of: "-") else { return nil }
        let venue = competitionName[competitionName.index(after: dashIndex)...].trimmingCharacters(in: .whitespaces)
        return venue.isEmpty ? nil : venue
    }

    private static func parsedDate(from apiMatch: AVPLeagueAPI.APIMatch) -> Date? {
        let candidates = [apiMatch.matchSchedule?.scheduleTime, apiMatch.startTime].compactMap { $0 }
        for candidate in candidates {
            if let date = scheduleDateFormatter.date(from: candidate) { return date }
            if let date = scheduleDateFormatterNoFraction.date(from: candidate) { return date }
        }
        return nil
    }

    private static func weekNumber(from competitionCode: String) -> Int? {
        guard competitionCode.hasPrefix("W"),
              let number = Int(competitionCode.dropFirst()) else { return nil }
        return number
    }

    private static func division(for genderCode: String?) -> GenderDivision? {
        switch genderCode?.uppercased() {
        case "F": return .women
        case "M": return .men
        default: return nil
        }
    }
}
