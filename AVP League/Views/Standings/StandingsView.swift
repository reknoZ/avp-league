import SwiftUI

struct StandingsView: View {
    @Environment(LeagueDataService.self) private var dataService
    @Bindable var seasonSelection: SeasonSelectionModel

    private var standings: [TeamStanding] {
        dataService.standings(for: seasonSelection.selectedSeason)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(standings) { standing in
                        StandingsRowView(standing: standing)
                    }
                } header: {
                    StandingsHeaderView()
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Standings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SeasonPickerBar(
                        season: seasonSelection.selectedSeason,
                        onPrevious: seasonSelection.selectPreviousSeason,
                        onNext: seasonSelection.selectNextSeason
                    )
                }
            }
            .refreshable {
                await dataService.refreshLiveScores()
            }
        }
    }
}

#Preview {
    StandingsView(seasonSelection: SeasonSelectionModel())
        .environment(LeagueDataService.shared)
}
