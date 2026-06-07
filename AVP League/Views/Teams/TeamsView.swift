import SwiftUI

struct TeamsView: View {
    @Environment(LeagueDataService.self) private var dataService
    @Bindable var seasonSelection: SeasonSelectionModel

    private var profiles: [TeamSeasonProfile] {
        dataService.teamProfiles(for: seasonSelection.selectedSeason)
    }

    var body: some View {
        NavigationStack {
            List(profiles) { profile in
                NavigationLink(value: profile.team) {
                    TeamRowView(team: profile.team, profile: profile)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Teams")
            .navigationDestination(for: AVPTeam.self) { team in
                TeamDetailView(team: team, initialSeason: seasonSelection.selectedSeason)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SeasonPickerBar(
                        season: seasonSelection.selectedSeason,
                        onPrevious: seasonSelection.selectPreviousSeason,
                        onNext: seasonSelection.selectNextSeason
                    )
                }
            }
        }
    }
}

#Preview {
    TeamsView(seasonSelection: SeasonSelectionModel())
        .environment(LeagueDataService.shared)
}
