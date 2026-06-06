import Foundation

struct LeagueMatch: Identifiable, Hashable {
    let id: String
    let seasonYear: Int
    let weekNumber: Int
    let date: Date
    let homeTeamID: String
    let awayTeamID: String
    let venue: String
    let division: GenderDivision
    let status: MatchStatus
    let result: SideMatchResult?

    var homeTeam: AVPTeam { AVPTeam.team(for: homeTeamID) }
    var awayTeam: AVPTeam { AVPTeam.team(for: awayTeamID) }

    var isPlayed: Bool {
        status == .completed
    }

    var isLive: Bool {
        status == .inProgress
    }

    func teamWon(_ teamID: String) -> Bool? {
        guard let result else { return nil }
        if homeTeamID == teamID {
            return result.homeSetsWon > result.awaySetsWon
        }
        if awayTeamID == teamID {
            return result.awaySetsWon > result.homeSetsWon
        }
        return nil
    }

    func teamSetsWon(_ teamID: String) -> Int? {
        guard let result else { return nil }
        if homeTeamID == teamID { return result.homeSetsWon }
        if awayTeamID == teamID { return result.awaySetsWon }
        return nil
    }

    func opponentSetsWon(for teamID: String) -> Int? {
        guard let result else { return nil }
        if homeTeamID == teamID { return result.awaySetsWon }
        if awayTeamID == teamID { return result.homeSetsWon }
        return nil
    }
}

struct ScheduleWeek: Identifiable, Hashable {
    let number: Int
    let startDate: Date
    let endDate: Date

    var id: Int { number }

    var title: String {
        "Week \(number)"
    }

    var dateRangeLabel: String {
        Self.dateRangeLabel(from: startDate, to: endDate)
    }

    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        return calendar
    }

    private static let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private static func dateRangeLabel(from start: Date, to end: Date) -> String {
        let startDay = calendar.startOfDay(for: start)
        let endDay = calendar.startOfDay(for: end)

        let startLabel = monthDayFormatter.string(from: startDay)
        let endLabel = monthDayFormatter.string(from: endDay)

        if calendar.isDate(startDay, inSameDayAs: endDay) {
            return startLabel
        }

        if calendar.isDate(startDay, equalTo: endDay, toGranularity: .month) {
            let dayFormatter = DateFormatter()
            dayFormatter.locale = Locale(identifier: "en_US_POSIX")
            dayFormatter.timeZone = TimeZone(identifier: "America/New_York")
            dayFormatter.dateFormat = "d"
            return "\(startLabel)–\(dayFormatter.string(from: endDay))"
        }

        return "\(startLabel) – \(endLabel)"
    }
}

enum ScheduleWeekCalculator {
    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        return calendar
    }

    static func weeks(for matches: [LeagueMatch]) -> [ScheduleWeek] {
        let grouped = Dictionary(grouping: matches, by: \.weekNumber)

        return grouped.keys.sorted().compactMap { number in
            guard let weekMatches = grouped[number], !weekMatches.isEmpty else { return nil }

            let sortedDates = weekMatches.map(\.date).sorted()
            let startDay = calendar.startOfDay(for: sortedDates[0])
            let endDay = calendar.startOfDay(for: sortedDates[sortedDates.count - 1])

            return ScheduleWeek(number: number, startDate: startDay, endDate: endDay)
        }
    }

    static func defaultWeek(in weeks: [ScheduleWeek], today: Date = Date()) -> ScheduleWeek? {
        guard !weeks.isEmpty else { return nil }

        let todayStart = calendar.startOfDay(for: today)

        if let currentWeek = weeks.first(where: {
            todayStart >= calendar.startOfDay(for: $0.startDate)
                && todayStart <= calendar.startOfDay(for: $0.endDate)
        }) {
            return currentWeek
        }

        if todayStart < calendar.startOfDay(for: weeks[0].startDate) {
            return weeks[0]
        }

        if let upcomingWeek = weeks.first(where: { calendar.startOfDay(for: $0.startDate) > todayStart }) {
            return upcomingWeek
        }

        return weeks.last
    }
}
