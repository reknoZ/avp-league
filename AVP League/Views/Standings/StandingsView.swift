import SwiftUI

struct StandingsView: View {
    @Environment(LeagueDataService.self) private var dataService
    @Bindable var seasonSelection: SeasonSelectionModel
    @State private var selectedCategory: StandingsCategory = .city

    private var standings: [TeamStanding] {
        dataService.standings(for: seasonSelection.selectedSeason, category: selectedCategory)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Standings", selection: $selectedCategory) {
                        ForEach(StandingsCategory.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }

                Section {
                    ForEach(standings) { standing in
                        StandingsRowView(standing: standing)
                    }
                } header: {
                    StandingsHeaderView(category: selectedCategory)
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
