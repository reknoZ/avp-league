import Foundation

enum MatchDateFormatter {
    static func format(_ date: Date, in timeZone: TimeZone) -> String {
        formatted(date, in: timeZone, dateFormat: "EEE, MM.dd.yyyy @ h:mm a")
    }

    static func formatTime(_ date: Date, in timeZone: TimeZone) -> String {
        formatted(date, in: timeZone, dateFormat: "h:mm a")
    }

    static func format(_ date: Date, venue: String) -> String {
        format(date, in: VenueTimeZone.timeZone(for: venue))
    }

    static func formatTime(_ date: Date, venue: String) -> String {
        formatTime(date, in: VenueTimeZone.timeZone(for: venue))
    }

    private static func formatted(_ date: Date, in timeZone: TimeZone, dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = dateFormat
        let formatted = formatter.string(from: date)
        let abbreviation = timeZone.abbreviation(for: date) ?? ""
        return abbreviation.isEmpty ? formatted : "\(formatted) \(abbreviation)"
    }

    private static let dayHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()

    static func formatDayHeader(_ date: Date) -> String {
        dayHeaderFormatter.string(from: date)
    }
}
