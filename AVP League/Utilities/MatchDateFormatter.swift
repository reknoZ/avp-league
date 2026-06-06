import Foundation

enum MatchDateFormatter {
    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        formatter.dateFormat = "EEE, MM.dd.yyyy @ h:mm a"
        return formatter
    }()

    static func format(_ date: Date) -> String {
        displayFormatter.string(from: date)
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
