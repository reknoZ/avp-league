import Foundation

enum VenueTimeZone {
    static func weekLocation(from venue: String) -> String {
        let parts = venue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count >= 2,
              let state = parts.last,
              state.count == 2,
              state.allSatisfy(\.isLetter) else {
            return venue
        }
        let city = parts[parts.count - 2]
        return "\(city), \(state)"
    }

    static func timeZone(for venue: String) -> TimeZone {
        if venue.uppercased().contains("NYC") {
            return TimeZone(identifier: "America/New_York")!
        }

        guard let state = stateCode(from: venue) else {
            return TimeZone(identifier: "America/New_York")!
        }

        return timeZone(forState: state)
    }

    private static func stateCode(from venue: String) -> String? {
        let parts = venue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        for part in parts.reversed() where part.count == 2 && part.allSatisfy(\.isLetter) {
            return part.uppercased()
        }
        return nil
    }

    private static func timeZone(forState state: String) -> TimeZone {
        switch state {
        case "CA", "NV", "WA", "OR":
            return TimeZone(identifier: "America/Los_Angeles")!
        case "AZ":
            return TimeZone(identifier: "America/Phoenix")!
        case "CO", "UT", "MT", "WY", "NM", "ID":
            return TimeZone(identifier: "America/Denver")!
        case "TX", "IL", "MN", "WI", "IA", "MO", "AR", "LA", "OK", "KS", "NE", "SD", "ND":
            return TimeZone(identifier: "America/Chicago")!
        default:
            return TimeZone(identifier: "America/New_York")!
        }
    }
}
