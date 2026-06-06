import SwiftUI

struct TeamDetailView: View {
    @Environment(LeagueDataService.self) private var dataService
    let team: AVPTeam
    let season: Season

    private var profile: TeamSeasonProfile? {
        dataService.profile(for: team, season: season)
    }

    private var standing: TeamStanding? {
        dataService.standings(for: season).first { $0.team.id == team.id }
    }

    private var matches: [LeagueMatch] {
        dataService.matches(for: team, season: season)
    }

    var body: some View {
        List {
            headerSection

            if let profile {
                TeamRosterSectionView(profile: profile)
                TeamEventsSectionView(events: profile.events)
            }

            TeamRecordSectionView(standing: standing)

            Section("Match History") {
                ForEach(matches) { match in
                    TeamMatchHistoryRowView(match: match, teamID: team.id)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(team.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        Section {
            HStack(spacing: 16) {
                TeamBadgeView(team: team)
                    .scaleEffect(1.4)
                    .padding(.trailing, 4)

                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(.title3.weight(.bold))
                    Text(team.city)
                        .foregroundStyle(.secondary)
                    Text(String(season.year))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    NavigationStack {
        TeamDetailView(team: PreviewData.team, season: PreviewData.season)
            .environment(LeagueDataService.shared)
    }
}
