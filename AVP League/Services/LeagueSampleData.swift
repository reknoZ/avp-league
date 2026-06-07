import Foundation

enum LeagueSampleData {
    // MARK: - Match builders

    static func matches(for year: Int) -> [LeagueMatch] {
        switch year {
        case 2024, 2025:
            return HistoricalMatchData.matches(for: year) ?? []
        case 2026: return season2026Matches
        default: return []
        }
    }

    static func teamProfiles(for year: Int) -> [TeamSeasonProfile] {
        HistoricalMatchData.teamProfiles(for: year) ?? []
    }

    // MARK: - Helpers

    private typealias SetLine = (Int, Int)

    private struct DayScores {
        var womenA: [SetLine]?
        var menA: [SetLine]?
        var womenB: [SetLine]?
        var menB: [SetLine]?

        static func fromWins(
            womenA: (Int, Int)? = nil, menA: (Int, Int)? = nil,
            womenB: (Int, Int)? = nil, menB: (Int, Int)? = nil
        ) -> DayScores {
            DayScores(
                womenA: womenA.map { defaultSets(homeWins: $0.0, awayWins: $0.1) },
                menA: menA.map { defaultSets(homeWins: $0.0, awayWins: $0.1) },
                womenB: womenB.map { defaultSets(homeWins: $0.0, awayWins: $0.1) },
                menB: menB.map { defaultSets(homeWins: $0.0, awayWins: $0.1) }
            )
        }
    }

    private static func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 14, minute: Int = 0, venue: String) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = VenueTimeZone.timeZone(for: venue)
        return Calendar.current.date(from: components) ?? Date()
    }

    private static func defaultSets(homeWins: Int, awayWins: Int) -> [(Int, Int)] {
        var sets: [(Int, Int)] = []
        for _ in 0..<homeWins { sets.append((21, 18)) }
        for _ in 0..<awayWins { sets.append((17, 21)) }
        return sets
    }

    private static func sideResult(division: GenderDivision, sets: [SetLine]) -> SideMatchResult {
        SideMatchResult(
            division: division,
            sets: sets.map { SetScore(homePoints: $0.0, awayPoints: $0.1) }
        )
    }

    private static func genderMatch(
        id: String, seasonYear: Int, week: Int,
        month: Int, day: Int, hour: Int,
        home: String, away: String, venue: String,
        division: GenderDivision,
        sets: [SetLine]? = nil
    ) -> LeagueMatch {
        var matchResult: SideMatchResult?
        if let sets {
            matchResult = sideResult(division: division, sets: sets)
        }
        return LeagueMatch(
            id: id, seasonYear: seasonYear, weekNumber: week,
            date: date(seasonYear, month, day, hour: hour, venue: venue),
            homeTeamID: home, awayTeamID: away, venue: venue,
            division: division,
            status: matchResult == nil ? .upcoming : .completed,
            result: matchResult
        )
    }

    private static func scheduleDay(
        seasonYear: Int, week: Int, month: Int, day: Int, venue: String,
        idPrefix: String, idStart: Int,
        pairingA: (String, String),
        pairingB: (String, String),
        scores: DayScores = DayScores()
    ) -> [LeagueMatch] {
        let (homeA, awayA) = pairingA
        let (homeB, awayB) = pairingB
        let hours = [11, 12, 15, 16]
        let divisions: [GenderDivision] = [.women, .men, .women, .men]
        let pairings = [(homeA, awayA), (homeA, awayA), (homeB, awayB), (homeB, awayB)]
        let scoreList: [[SetLine]?] = [scores.womenA, scores.menA, scores.womenB, scores.menB]

        return (0..<4).map { index in
            let (home, away) = pairings[index]
            return genderMatch(
                id: String(format: "%@-%02d", idPrefix, idStart + index),
                seasonYear: seasonYear, week: week,
                month: month, day: day, hour: hours[index],
                home: home, away: away, venue: venue,
                division: divisions[index],
                sets: scoreList[index]
            )
        }
    }

    private static func crossoverDay(
        seasonYear: Int, week: Int, month: Int, day: Int, venue: String,
        idPrefix: String, idStart: Int,
        day1PairingA: (String, String),
        day1PairingB: (String, String),
        scores: DayScores = DayScores()
    ) -> [LeagueMatch] {
        scheduleDay(
            seasonYear: seasonYear, week: week, month: month, day: day, venue: venue,
            idPrefix: idPrefix, idStart: idStart,
            pairingA: (day1PairingA.0, day1PairingB.0),
            pairingB: (day1PairingA.1, day1PairingB.1),
            scores: scores
        )
    }

    private static func scheduleWeek(
        seasonYear: Int, week: Int, venue: String,
        day1: (month: Int, day: Int), day2: (month: Int, day: Int),
        pairingA: (String, String), pairingB: (String, String),
        idPrefix: String, idStart: Int,
        day1Scores: DayScores = DayScores(),
        day2Scores: DayScores = DayScores()
    ) -> [LeagueMatch] {
        let dayOne = scheduleDay(
            seasonYear: seasonYear, week: week,
            month: day1.month, day: day1.day, venue: venue,
            idPrefix: idPrefix, idStart: idStart,
            pairingA: pairingA, pairingB: pairingB,
            scores: day1Scores
        )
        let dayTwo = crossoverDay(
            seasonYear: seasonYear, week: week,
            month: day2.month, day: day2.day, venue: venue,
            idPrefix: idPrefix, idStart: idStart + 4,
            day1PairingA: pairingA, day1PairingB: pairingB,
            scores: day2Scores
        )
        return dayOne + dayTwo
    }

    // MARK: - 2026 Season

    private static let season2026Matches: [LeagueMatch] = {
        func week(
            _ week: Int, _ venue: String,
            _ day1: (Int, Int), _ day2: (Int, Int),
            _ pairingA: (String, String), _ pairingB: (String, String),
            idStart: Int,
            day1Scores: DayScores = DayScores(),
            day2Scores: DayScores = DayScores()
        ) -> [LeagueMatch] {
            scheduleWeek(
                seasonYear: 2026, week: week, venue: venue,
                day1: (month: day1.0, day: day1.1),
                day2: (month: day2.0, day: day2.1),
                pairingA: pairingA, pairingB: pairingB,
                idPrefix: "26", idStart: idStart,
                day1Scores: day1Scores, day2Scores: day2Scores
            )
        }

        return
            week(1, "Belmar, NJ", (5, 30), (5, 31), ("lal", "sds"), ("nyn", "bb"), idStart: 1) +
            week(2, "Aspen, CO", (6, 6), (6, 7), ("pbp", "mm"), ("bb", "nyn"), idStart: 9) +
            week(3, "Miami Beach, FL", (6, 12), (6, 13), ("aa", "mm"), ("dd", "pbp"), idStart: 17) +
            week(4, "Las Vegas, NV", (6, 19), (6, 20), ("lal", "dd"), ("pbp", "nyn"), idStart: 25) +
            week(5, "Long Beach, CA", (7, 11), (7, 12), ("lal", "bb"), ("mm", "dd"), idStart: 33) +
            week(6, "New York, NY", (7, 18), (7, 19), ("sds", "pbp"), ("nyn", "aa"), idStart: 41) +
            week(7, "East Hampton, NY", (7, 25), (7, 26), ("sds", "aa"), ("mm", "bb"), idStart: 49) +
            week(8, "Dallas, TX", (8, 7), (8, 8), ("lal", "sds"), ("aa", "dd"), idStart: 57)
    }()
}
