import SwiftUI

struct StandingsView: View {
    @Environment(LeagueDataService.self) private var dataService
    @Bindable var seasonSelection: SeasonSelectionModel
    @State private var selectedCategory: StandingsCategory = .city

    private var standings: [TeamStanding] {
        dataService.standings(for: seasonSelection.selectedSeason, category: selectedCategory)
    }

    private var championshipResults: [ChampionshipFinish] {
        dataService.championshipResults(for: seasonSelection.selectedSeason)
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

                if selectedCategory == .city, !championshipResults.isEmpty {
                    Section("Championship Results") {
                        ChampionshipResultsView(results: championshipResults)
                    }
                }

                Section {
                    ForEach(Array(standings.enumerated()), id: \.element.id) { index, standing in
                        StandingsRowView(standing: standing)

                        if selectedCategory == .city,
                           index == SeasonStructure.playoffTeamCount - 1,
                           standings.count > SeasonStructure.playoffTeamCount {
                            PlayoffCutlineRow()
                        }
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

private struct PlayoffCutlineRow: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.secondary.opacity(0.25))
                .frame(height: 1)
            Text("Championship cutline")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .fixedSize()
            Rectangle()
                .fill(Color.secondary.opacity(0.25))
                .frame(height: 1)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
    }
}

#Preview {
    StandingsView(seasonSelection: SeasonSelectionModel())
        .environment(LeagueDataService.shared)
}
