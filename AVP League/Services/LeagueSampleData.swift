import Foundation

enum LeagueSampleData {
    // MARK: - Match builders

    static func matches(for year: Int) -> [LeagueMatch] {
        switch year {
        case 2024: return season2024Matches
        case 2025: return season2025Matches
        case 2026: return season2026Matches
        default: return []
        }
    }

    static func teamProfiles(for year: Int) -> [TeamSeasonProfile] {
        switch year {
        case 2024: return season2024Profiles
        case 2025: return season2025Profiles
        case 2026: return season2026Profiles
        default: return []
        }
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

    private static func legacyPairedMatches(
        id: String, seasonYear: Int, week: Int, month: Int, day: Int,
        home: String, away: String, venue: String,
        menHome: Int, menAway: Int, womenHome: Int, womenAway: Int,
        womenHour: Int = 11, menHour: Int = 12
    ) -> [LeagueMatch] {
        [
            genderMatch(
                id: "\(id)-F", seasonYear: seasonYear, week: week,
                month: month, day: day, hour: womenHour,
                home: home, away: away, venue: venue,
                division: .women,
                sets: defaultSets(homeWins: womenHome, awayWins: womenAway)
            ),
            genderMatch(
                id: "\(id)-M", seasonYear: seasonYear, week: week,
                month: month, day: day, hour: menHour,
                home: home, away: away, venue: venue,
                division: .men,
                sets: defaultSets(homeWins: menHome, awayWins: menAway)
            ),
        ]
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

    private static let season2026Profiles: [TeamSeasonProfile] = [
        profile("nyn", 2026, "Chaim Schalk", "James Shaw", "Toni Rodriguez", "Molly Shaw",
                ["Belmar", "Aspen", "Miami", "Las Vegas", "Long Beach", "New York", "East Hampton", "Dallas"]),
        profile("bb", 2026, "Derek Bradford", "Evan Cory", "Lexy Denaburg", "Julia Donlin",
                ["Belmar", "Aspen", "Miami", "Las Vegas", "Long Beach", "New York", "East Hampton", "Dallas"]),
        profile("lal", 2026, "Hagen Smith", "Logan Webber", "Maddie Anderson", "Alaina Chacon",
                ["Belmar", "Aspen", "Miami", "Las Vegas", "Long Beach", "New York", "East Hampton", "Dallas"]),
        profile("sds", 2026, "Chase Budinger", "Miles Evans", "Megan Rice", "Geena Urango",
                ["Belmar", "Aspen", "Miami", "Las Vegas", "Long Beach", "New York", "East Hampton", "Dallas"]),
        profile("pbp", 2026, "Trevor Crabb", "Phil Dalhausser", "Melissa Humana-Paredes", "Brandie Wilkerson",
                ["Belmar", "Aspen", "Miami", "Las Vegas", "Long Beach", "New York", "East Hampton", "Dallas"]),
        profile("mm", 2026, "Taylor Crabb", "Andy Benesh", "Kelly Cheng", "Megan Kraft",
                ["Belmar", "Aspen", "Miami", "Las Vegas", "Long Beach", "New York", "East Hampton", "Dallas"]),
        profile("aa", 2026, "Troy Field", "Ryan Wilcox", "Taryn Brasher", "Kristen Cruz",
                ["Belmar", "Aspen", "Miami", "Las Vegas", "Long Beach", "New York", "East Hampton", "Dallas"]),
        profile("dd", 2026, "Paul Lotman", "Miles Partain", "Kylie DeBerg", "Betsi Flint",
                ["Belmar", "Aspen", "Miami", "Las Vegas", "Long Beach", "New York", "East Hampton", "Dallas"]),
    ]

    // MARK: - 2025 Season

    private static let season2025Matches: [LeagueMatch] = {
        func m(
            id: String, week: Int, month: Int, day: Int, home: String, away: String, venue: String,
            menHome: Int, menAway: Int, womenHome: Int, womenAway: Int,
            womenHour: Int = 11, menHour: Int = 12
        ) -> [LeagueMatch] {
            legacyPairedMatches(
                id: id, seasonYear: 2025, week: week, month: month, day: day,
                home: home, away: away, venue: venue,
                menHome: menHome, menAway: menAway, womenHome: womenHome, womenAway: womenAway,
                womenHour: womenHour, menHour: menHour
            )
        }

        return
            m(id: "25-01", week: 1, month: 5, day: 24, home: "bb", away: "nyn", venue: "Belmar, NJ",
              menHome: 2, menAway: 1, womenHome: 2, womenAway: 0) +
            m(id: "25-02", week: 1, month: 5, day: 24, home: "lal", away: "pbp", venue: "Belmar, NJ",
              menHome: 1, menAway: 2, womenHome: 2, womenAway: 1, womenHour: 15, menHour: 16) +
            m(id: "25-03", week: 2, month: 6, day: 7, home: "sds", away: "mm", venue: "Aspen, CO",
              menHome: 2, menAway: 0, womenHome: 1, womenAway: 2) +
            m(id: "25-04", week: 2, month: 6, day: 7, home: "aa", away: "dd", venue: "Aspen, CO",
              menHome: 0, menAway: 2, womenHome: 2, womenAway: 1, womenHour: 15, menHour: 16) +
            m(id: "25-05", week: 3, month: 6, day: 21, home: "bb", away: "sds", venue: "Miami Beach, FL",
              menHome: 2, menAway: 1, womenHome: 2, womenAway: 0) +
            m(id: "25-06", week: 4, month: 7, day: 5, home: "nyn", away: "lal", venue: "Las Vegas, NV",
              menHome: 2, menAway: 0, womenHome: 1, womenAway: 2) +
            m(id: "25-07", week: 5, month: 7, day: 19, home: "pbp", away: "bb", venue: "Hermosa Beach, CA",
              menHome: 1, menAway: 2, womenHome: 0, womenAway: 2) +
            m(id: "25-08", week: 6, month: 8, day: 2, home: "mm", away: "aa", venue: "Central Park, NYC",
              menHome: 2, menAway: 1, womenHome: 2, womenAway: 1) +
            m(id: "25-09", week: 7, month: 8, day: 16, home: "dd", away: "nyn", venue: "East Hampton, NY",
              menHome: 1, menAway: 2, womenHome: 2, womenAway: 0) +
            m(id: "25-10", week: 8, month: 8, day: 30, home: "bb", away: "mm", venue: "Dallas, TX",
              menHome: 2, menAway: 0, womenHome: 2, womenAway: 1) +
            m(id: "25-11", week: 9, month: 9, day: 6, home: "bb", away: "lal", venue: "Chicago, IL",
              menHome: 2, menAway: 1, womenHome: 2, womenAway: 0)
    }()

    private static let season2025Profiles: [TeamSeasonProfile] = [
        profile("bb", 2025, "Evan Cory", "Derek Bradford", "Lexy Denaburg", "Julia Donlin",
                ["Belmar", "Miami", "Los Angeles", "Dallas", "Chicago"]),
        profile("nyn", 2025, "Chaim Schalk", "James Shaw", "Toni Rodriguez", "Molly Shaw",
                ["Belmar", "Las Vegas", "Central Park", "East Hampton"]),
        profile("lal", 2025, "Logan Webber", "Hagen Smith", "Alaina Chacon", "Maddie Anderson",
                ["Belmar", "Las Vegas", "Chicago"]),
        profile("pbp", 2025, "Phil Dalhausser", "Trevor Crabb", "Brandie Wilkerson", "Melissa Humana-Paredes",
                ["Belmar", "Los Angeles"]),
        profile("sds", 2025, "Miles Evans", "Chase Budinger", "Geena Urango", "Megan Rice",
                ["Aspen", "Miami", "Chicago"]),
        profile("mm", 2025, "Andy Benesh", "Taylor Crabb", "Megan Kraft", "Kelly Cheng",
                ["Aspen", "Central Park", "Dallas"]),
        profile("aa", 2025, "Ryan Wilcox", "Troy Field", "Kristen Cruz", "Taryn Brasher",
                ["Aspen", "Central Park"]),
        profile("dd", 2025, "Miles Partain", "Paul Lotman", "Betsi Flint", "Kylie DeBerg",
                ["Aspen", "East Hampton"]),
    ]

    // MARK: - 2024 Season

    private static let season2024Matches: [LeagueMatch] = {
        func m(
            id: String, week: Int, month: Int, day: Int, home: String, away: String, venue: String,
            menHome: Int, menAway: Int, womenHome: Int, womenAway: Int,
            womenHour: Int = 11, menHour: Int = 12
        ) -> [LeagueMatch] {
            legacyPairedMatches(
                id: id, seasonYear: 2024, week: week, month: month, day: day,
                home: home, away: away, venue: venue,
                menHome: menHome, menAway: menAway, womenHome: womenHome, womenAway: womenAway,
                womenHour: womenHour, menHour: menHour
            )
        }

        return
            m(id: "24-01", week: 1, month: 6, day: 1, home: "nyn", away: "bb", venue: "Belmar, NJ",
              menHome: 2, menAway: 1, womenHome: 2, womenAway: 0) +
            m(id: "24-02", week: 1, month: 6, day: 1, home: "lal", away: "sds", venue: "Belmar, NJ",
              menHome: 2, menAway: 0, womenHome: 1, womenAway: 2, womenHour: 15, menHour: 16) +
            m(id: "24-03", week: 2, month: 6, day: 15, home: "pbp", away: "mm", venue: "Aspen, CO",
              menHome: 2, menAway: 1, womenHome: 2, womenAway: 0) +
            m(id: "24-04", week: 2, month: 6, day: 15, home: "aa", away: "dd", venue: "Aspen, CO",
              menHome: 1, menAway: 2, womenHome: 2, womenAway: 1, womenHour: 15, menHour: 16) +
            m(id: "24-05", week: 3, month: 7, day: 6, home: "nyn", away: "pbp", venue: "Miami Beach, FL",
              menHome: 2, menAway: 0, womenHome: 2, womenAway: 1) +
            m(id: "24-06", week: 4, month: 7, day: 20, home: "bb", away: "aa", venue: "Las Vegas, NV",
              menHome: 1, menAway: 2, womenHome: 2, womenAway: 0) +
            m(id: "24-07", week: 5, month: 8, day: 3, home: "sds", away: "dd", venue: "Hermosa Beach, CA",
              menHome: 2, menAway: 1, womenHome: 0, womenAway: 2) +
            m(id: "24-08", week: 6, month: 8, day: 17, home: "lal", away: "mm", venue: "Central Park, NYC",
              menHome: 2, menAway: 0, womenHome: 1, womenAway: 2) +
            m(id: "24-09", week: 7, month: 8, day: 31, home: "nyn", away: "sds", venue: "East Hampton, NY",
              menHome: 2, menAway: 1, womenHome: 2, womenAway: 0) +
            m(id: "24-10", week: 8, month: 9, day: 7, home: "nyn", away: "lal", venue: "Chicago, IL",
              menHome: 2, menAway: 1, womenHome: 2, womenAway: 1)
    }()

    private static let season2024Profiles: [TeamSeasonProfile] = [
        profile("nyn", 2024, "Chaim Schalk", "James Shaw", "Toni Rodriguez", "Molly Shaw",
                ["Belmar", "Miami", "East Hampton", "Chicago"]),
        profile("bb", 2024, "Evan Cory", "Miles Partain", "Julia Donlin", "Lexy Denaburg",
                ["Belmar", "Las Vegas"]),
        profile("lal", 2024, "Logan Webber", "Hagen Smith", "Maddie Anderson", "Alaina Chacon",
                ["Belmar", "Central Park", "Chicago"]),
        profile("sds", 2024, "Chase Budinger", "Miles Evans", "Megan Rice", "Geena Urango",
                ["Belmar", "Hermosa Beach", "East Hampton"]),
        profile("pbp", 2024, "Trevor Crabb", "Phil Dalhausser", "Melissa Humana-Paredes", "Brandie Wilkerson",
                ["Aspen", "Miami"]),
        profile("mm", 2024, "Taylor Crabb", "Andy Benesh", "Kelly Cheng", "Sarah Sponcil",
                ["Aspen", "Central Park"]),
        profile("aa", 2024, "Troy Field", "Ryan Wilcox", "Kristen Cruz", "Taryn Brasher",
                ["Aspen", "Las Vegas"]),
        profile("dd", 2024, "Paul Lotman", "Miles Partain", "Kylie DeBerg", "Betsi Flint",
                ["Aspen", "Hermosa Beach"]),
    ]

    private static func profile(
        _ teamID: String, _ year: Int,
        _ m1: String, _ m2: String, _ w1: String, _ w2: String,
        _ events: [String]
    ) -> TeamSeasonProfile {
        TeamSeasonProfile(
            teamID: teamID,
            seasonYear: year,
            mensPair: PlayerPair(player1: m1, player2: m2),
            womensPair: PlayerPair(player1: w1, player2: w2),
            events: events
        )
    }
}
