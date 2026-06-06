import SwiftUI

struct TeamMatchHistoryRowView: View {
    let match: LeagueMatch
    let teamID: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(MatchDateFormatter.format(match.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(match.division.shortLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                resultBadge
            }

            MatchSetScorecardView(
                homeTeam: match.homeTeam,
                awayTeam: match.awayTeam,
                status: match.status,
                result: match.result
            )
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var resultBadge: some View {
        Group {
            switch match.status {
            case .upcoming:
                Text("Scheduled")
                    .foregroundStyle(.orange)
            case .inProgress:
                Text("Live")
                    .foregroundStyle(.red)
            case .completed:
                if let won = match.teamWon(teamID),
                   let teamSets = match.teamSetsWon(teamID),
                   let oppSets = match.opponentSetsWon(for: teamID) {
                    Text("\(won ? "W" : "L") \(teamSets)-\(oppSets)")
                        .foregroundStyle(won ? .green : .red)
                }
            }
        }
        .font(.caption.weight(.semibold).monospacedDigit())
    }
}

#Preview {
    List {
        TeamMatchHistoryRowView(match: PreviewData.match, teamID: PreviewData.team.id)
    }
}
