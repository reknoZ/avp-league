import SwiftUI

struct StandingsRowView: View {
    let standing: TeamStanding

    var body: some View {
        HStack(spacing: 12) {
            Text("\(standing.rank)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(standing.rank <= 3 ? .primary : .secondary)
                .frame(width: 24, alignment: .trailing)

            TeamBadgeView(team: standing.team)

            VStack(alignment: .leading, spacing: 2) {
                Text(standing.team.name)
                    .font(.body.weight(.medium))
                Text(standing.team.city)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(standing.matchPoints) pts")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                Text("\(standing.record) · \(standing.setDifferentialDisplay) sets")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    List {
        StandingsRowView(standing: PreviewData.standing)
    }
}
