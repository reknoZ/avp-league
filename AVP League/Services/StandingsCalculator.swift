import Foundation

enum StandingsCalculator {
    static func standings(for matches: [LeagueMatch], teams: [AVPTeam] = AVPTeam.allTeams) -> [TeamStanding] {
        var stats: [String: (matchPoints: Int, wins: Int, losses: Int, setsWon: Int, setsLost: Int)] = [:]

        for team in teams {
            stats[team.id] = (0, 0, 0, 0, 0)
        }

        for match in matches where match.status == .completed {
            accumulateSide(
                homeID: match.homeTeamID,
                awayID: match.awayTeamID,
                result: match.result,
                stats: &stats
            )
        }

        let sorted = teams.map { team -> TeamStanding in
            let s = stats[team.id] ?? (0, 0, 0, 0, 0)
            return TeamStanding(
                team: team,
                rank: 0,
                matchPoints: s.matchPoints,
                genderMatchWins: s.wins,
                genderMatchLosses: s.losses,
                setsWon: s.setsWon,
                setsLost: s.setsLost
            )
        }
        .sorted { lhs, rhs in
            if lhs.matchPoints != rhs.matchPoints { return lhs.matchPoints > rhs.matchPoints }
            if lhs.genderMatchWins != rhs.genderMatchWins { return lhs.genderMatchWins > rhs.genderMatchWins }
            return lhs.setDifferential > rhs.setDifferential
        }

        return sorted.enumerated().map { index, standing in
            TeamStanding(
                team: standing.team,
                rank: index + 1,
                matchPoints: standing.matchPoints,
                genderMatchWins: standing.genderMatchWins,
                genderMatchLosses: standing.genderMatchLosses,
                setsWon: standing.setsWon,
                setsLost: standing.setsLost
            )
        }
    }

    private static func accumulateSide(
        homeID: String,
        awayID: String,
        result: SideMatchResult?,
        stats: inout [String: (matchPoints: Int, wins: Int, losses: Int, setsWon: Int, setsLost: Int)]
    ) {
        guard let result else { return }

        let homeSets = result.homeSetsWon
        let awaySets = result.awaySetsWon

        stats[homeID]?.setsWon += homeSets
        stats[homeID]?.setsLost += awaySets
        stats[awayID]?.setsWon += awaySets
        stats[awayID]?.setsLost += homeSets

        stats[homeID]?.matchPoints += matchPoints(setsWon: homeSets, setsLost: awaySets)
        stats[awayID]?.matchPoints += matchPoints(setsWon: awaySets, setsLost: homeSets)

        if homeSets > awaySets {
            stats[homeID]?.wins += 1
            stats[awayID]?.losses += 1
        } else if awaySets > homeSets {
            stats[awayID]?.wins += 1
            stats[homeID]?.losses += 1
        }
    }

    /// Standings points by set result: 2-0 → 3, 2-1 → 2, 1-2 → 1, 0-2 → 0.
    static func matchPoints(setsWon: Int, setsLost: Int) -> Int {
        switch (setsWon, setsLost) {
        case (2, 0): 3
        case (2, 1): 2
        case (1, 2): 1
        case (0, 2): 0
        default: 0
        }
    }
}
