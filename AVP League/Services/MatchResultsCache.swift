import Foundation

enum MatchResultsCache {
    private struct Payload: Codable {
        let seasonYear: Int
        let savedAt: Date
        let matches: [LeagueMatch]
    }

    private static let cacheVersion = 1

    private static var cacheURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent("match-results-v\(cacheVersion).json")
    }

    static func load(seasonYear: Int) -> (matches: [LeagueMatch], savedAt: Date)? {
        guard FileManager.default.fileExists(atPath: cacheURL.path) else { return nil }

        do {
            let data = try Data(contentsOf: cacheURL)
            let payload = try JSONDecoder().decode(Payload.self, from: data)
            guard payload.seasonYear == seasonYear else { return nil }
            return (payload.matches, payload.savedAt)
        } catch {
            return nil
        }
    }

    static func save(_ matches: [LeagueMatch], seasonYear: Int) {
        let payload = Payload(seasonYear: seasonYear, savedAt: Date(), matches: matches)

        do {
            let directory = cacheURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(payload)
            try data.write(to: cacheURL, options: .atomic)
        } catch {
            // Cache failures should not affect live score updates.
        }
    }

    static func merge(_ cached: [LeagueMatch], into schedule: [LeagueMatch]) -> [LeagueMatch] {
        let cachedByID = Dictionary(uniqueKeysWithValues: cached.map { ($0.id, $0) })
        return schedule.map { cachedByID[$0.id] ?? $0 }
    }
}
