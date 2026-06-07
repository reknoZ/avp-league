import SwiftUI

struct TeamRowView: View {
    let team: AVPTeam
    let profile: TeamSeasonProfile?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(team.name)
                .font(.body.weight(.semibold))

            if let profile {
                Text(profile.mensPair.display)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(profile.womensPair.display)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
    }
}

#Preview {
    List {
        TeamRowView(team: PreviewData.team, profile: PreviewData.profile)
    }
}
