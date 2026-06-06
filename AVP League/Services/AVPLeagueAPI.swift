import Foundation

enum AVPLeagueAPI {
    static let eventID = 51
    static let baseURL = URL(string: "https://volleyballapi.web4data.co.uk/api")!

    struct APIMatch: Decodable {
        let competitionCode: String
        let competitionName: String
        let matchNo: Int
        let matchState: String?
        let teamA: APITeam?
        let teamB: APITeam?
        let sets: [APISet]
        let matchSchedule: APIMatchSchedule?
        let startTime: String?

        enum CodingKeys: String, CodingKey {
            case competitionCode = "CompetitionCode"
            case competitionName = "CompetitionName"
            case matchNo = "MatchNo"
            case matchState = "MatchState"
            case teamA = "TeamA"
            case teamB = "TeamB"
            case sets = "Sets"
            case matchSchedule = "MatchSchedule"
            case startTime = "StartTime"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            competitionCode = try container.decode(String.self, forKey: .competitionCode)
            competitionName = try container.decode(String.self, forKey: .competitionName)
            matchNo = try container.decode(Int.self, forKey: .matchNo)
            matchState = try container.decodeIfPresent(String.self, forKey: .matchState)
            teamA = try container.decodeIfPresent(APITeam.self, forKey: .teamA)
            teamB = try container.decodeIfPresent(APITeam.self, forKey: .teamB)
            sets = try container.decodeIfPresent([APISet].self, forKey: .sets) ?? []
            matchSchedule = try container.decodeIfPresent(APIMatchSchedule.self, forKey: .matchSchedule)
            startTime = try container.decodeIfPresent(String.self, forKey: .startTime)
        }
    }

    struct APITeam: Decodable {
        let name: String?
        let captain: APIPlayer?

        enum CodingKeys: String, CodingKey {
            case name = "Name"
            case captain = "Captain"
        }
    }

    struct APIPlayer: Decodable {
        let gender: String?

        enum CodingKeys: String, CodingKey {
            case gender = "Gender"
        }
    }

    struct APISet: Decodable {
        let setNo: Int
        let a: Int
        let b: Int

        enum CodingKeys: String, CodingKey {
            case setNo = "SetNo"
            case a = "A"
            case b = "B"
        }
    }

    struct APIMatchSchedule: Decodable {
        let scheduleTime: String?
        let courtName: String?

        enum CodingKeys: String, CodingKey {
            case scheduleTime = "ScheduleTime"
            case courtName = "CourtName"
        }
    }

    static func fetchMatches(eventID: Int = eventID) async throws -> [APIMatch] {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("matches/byevent/\(eventID)"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [URLQueryItem(name: "noStats", value: "1")]

        var request = URLRequest(url: components.url!)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode([APIMatch].self, from: data)
    }
}
