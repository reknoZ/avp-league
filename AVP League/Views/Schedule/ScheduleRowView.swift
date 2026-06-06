import SwiftUI

struct ScheduleRowView: View {
    let match: LeagueMatch

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(MatchDateFormatter.format(match.date))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(match.division.shortLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            MatchSetScorecardView(
                homeTeam: match.homeTeam,
                awayTeam: match.awayTeam,
                status: match.status,
                result: match.result
            )

            Label(match.venue, systemImage: "mappin.and.ellipse")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview("Played") {
    List {
        ScheduleRowView(match: PreviewData.match)
    }
}

#Preview("Upcoming") {
    List {
        ScheduleRowView(
            match: LeagueDataService.shared.matches(for: PreviewData.season)
                .first { $0.status == .upcoming }!
        )
    }
}
