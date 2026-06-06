import SwiftUI

struct TeamBadgeView: View {
    let team: AVPTeam

    var body: some View {
        Text(team.shortName)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(TeamColor.color(for: team), in: RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    HStack {
        ForEach(AVPTeam.allTeams.prefix(4)) { team in
            TeamBadgeView(team: team)
        }
    }
    .padding()
}
