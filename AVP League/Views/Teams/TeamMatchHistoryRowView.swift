import SwiftUI

struct TeamMatchHistoryRowView: View {
    let match: LeagueMatch

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                MatchDateTimeLabel(date: match.date, venue: match.venue, font: .caption)
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

            Label(VenueTimeZone.weekLocation(from: match.venue), systemImage: "mappin.and.ellipse")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    List {
        TeamMatchHistoryRowView(match: PreviewData.match)
    }
}
