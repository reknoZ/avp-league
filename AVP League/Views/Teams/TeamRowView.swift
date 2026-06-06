import SwiftUI

struct TeamRowView: View {
    let team: AVPTeam
    let profile: TeamSeasonProfile?

    var body: some View {
        HStack(spacing: 12) {
            TeamBadgeView(team: team)

            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.body.weight(.semibold))
                Text(team.city)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let profile {
                    Text("\(profile.mensPair.display) · \(profile.womensPair.display)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    List {
        TeamRowView(team: PreviewData.team, profile: PreviewData.profile)
    }
}
