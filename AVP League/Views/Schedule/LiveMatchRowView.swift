import SwiftUI

struct LiveMatchRowView: View {
    let match: LeagueMatch

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                liveHeader
                Spacer()
                MatchDateTimeLabel(date: match.date, venue: match.venue, style: .timeOnly, font: .caption)
                Text(match.division.shortLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            MatchSetScorecardView(
                homeTeam: match.homeTeam,
                awayTeam: match.awayTeam,
                status: match.status,
                result: match.result,
                showsLiveBadge: false
            )
        }
        .padding(.vertical, 6)
    }

    private var liveHeader: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(.red)
                .frame(width: 8, height: 8)
            Text("Live Now")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    List {
        LiveMatchRowView(
            match: LeagueMatch(
                id: "preview-live",
                seasonYear: 2026,
                weekNumber: 2,
                date: .now,
                homeTeamID: "BB",
                awayTeamID: "NYN",
                venue: "Aspen, CO",
                division: .men,
                status: .inProgress,
                result: SideMatchResult(
                    division: .men,
                    sets: [
                        SetScore(homePoints: 21, awayPoints: 18),
                        SetScore(homePoints: 15, awayPoints: 12)
                    ]
                )
            )
        )
        .listRowBackground(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.red.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(.red.opacity(0.35), lineWidth: 1.5)
                )
                .padding(.vertical, 4)
        )
        .listRowSeparator(.hidden)
    }
    .listStyle(.insetGrouped)
}
