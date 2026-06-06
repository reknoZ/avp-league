import SwiftUI

struct MatchTeamsLineView: View {
    let homeTeam: AVPTeam
    let awayTeam: AVPTeam

    var body: some View {
        HStack(spacing: 8) {
            TeamBadgeView(team: homeTeam)
            Text(homeTeam.shortName)
                .fontWeight(.semibold)
            Text("vs")
                .foregroundStyle(.secondary)
            TeamBadgeView(team: awayTeam)
            Text(awayTeam.shortName)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

#Preview {
    MatchTeamsLineView(homeTeam: PreviewData.match.homeTeam, awayTeam: PreviewData.match.awayTeam)
        .padding()
}
