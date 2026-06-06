import SwiftUI

struct MatchSetScorecardView: View {
    let homeTeam: AVPTeam
    let awayTeam: AVPTeam
    let status: MatchStatus
    let result: SideMatchResult?
    var showsLiveBadge = true

    private let setCount = 3
    private let setColumnWidth: CGFloat = 28

    var body: some View {
        switch status {
        case .upcoming:
            upcomingLayout
        case .inProgress:
            inProgressLayout
        case .completed:
            completedLayout
        }
    }

    private var upcomingLayout: some View {
        VStack(alignment: .leading, spacing: 8) {
            teamName(homeTeam.name, won: nil)
            teamName(awayTeam.name, won: nil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var inProgressLayout: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsLiveBadge {
                HStack {
                    Spacer()
                    liveBadge
                }
            }

            if let result, !result.sets.isEmpty {
                Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 8) {
                    scoreRow(name: homeTeam.name, isHome: true, result: result, colorWinners: false)
                    scoreRow(name: awayTeam.name, isHome: false, result: result, colorWinners: false)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    teamName(homeTeam.name, won: nil)
                    teamName(awayTeam.name, won: nil)
                }
            }
        }
    }

    private var completedLayout: some View {
        Group {
            if let result {
                Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 8) {
                    scoreRow(name: homeTeam.name, isHome: true, result: result, colorWinners: true)
                    scoreRow(name: awayTeam.name, isHome: false, result: result, colorWinners: true)
                }
            }
        }
    }

    private var liveBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(.red)
                .frame(width: 6, height: 6)
            Text("Live")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.red)
        }
    }

    private func scoreRow(
        name: String,
        isHome: Bool,
        result: SideMatchResult,
        colorWinners: Bool
    ) -> some View {
        let teamWon = isHome
            ? result.homeSetsWon > result.awaySetsWon
            : result.awaySetsWon > result.homeSetsWon

        return GridRow {
            teamName(name, won: colorWinners ? teamWon : nil)

            ForEach(0..<setCount, id: \.self) { index in
                let set = result.sets[safe: index]
                let teamPoints = isHome ? set?.homePoints : set?.awayPoints
                let opponentPoints = isHome ? set?.awayPoints : set?.homePoints
                setScore(teamPoints: teamPoints, opponentPoints: opponentPoints)
            }
        }
    }

    private func teamName(_ name: String, won: Bool?) -> some View {
        Text(name)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(teamNameColor(won: won))
            .lineLimit(2)
            .minimumScaleFactor(0.85)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func teamNameColor(won: Bool?) -> Color {
        guard let won else { return .primary }
        return won ? .green : .red
    }

    private func setScore(teamPoints: Int?, opponentPoints: Int?) -> some View {
        Text(teamPoints.map(String.init) ?? "—")
            .font(.subheadline.monospacedDigit())
            .foregroundStyle(setScoreColor(teamPoints: teamPoints, opponentPoints: opponentPoints))
            .frame(width: setColumnWidth, alignment: .trailing)
    }

    private func setScoreColor(teamPoints: Int?, opponentPoints: Int?) -> Color {
        guard let teamPoints, let opponentPoints else { return .secondary }
        if teamPoints > opponentPoints { return .green }
        if teamPoints < opponentPoints { return .red }
        return .primary
    }
}

struct MatchScoreSummaryView: View {
    let match: LeagueMatch

    var body: some View {
        MatchSetScorecardView(
            homeTeam: match.homeTeam,
            awayTeam: match.awayTeam,
            status: match.status,
            result: match.result
        )
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview("Played") {
    MatchScoreSummaryView(match: PreviewData.match)
        .padding()
}

#Preview("Upcoming") {
    MatchSetScorecardView(
        homeTeam: PreviewData.match.homeTeam,
        awayTeam: PreviewData.match.awayTeam,
        status: .upcoming,
        result: nil
    )
    .padding()
}
