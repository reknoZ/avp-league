import SwiftUI

struct TeamDetailView: View {
    @Environment(LeagueDataService.self) private var dataService
    let team: AVPTeam
    let initialSeason: Season

    @State private var selectedSeason: Season

    init(team: AVPTeam, initialSeason: Season) {
        self.team = team
        self.initialSeason = initialSeason
        _selectedSeason = State(initialValue: initialSeason)
    }

    private var profile: TeamSeasonProfile? {
        dataService.profile(for: team, season: selectedSeason)
    }

    private var standing: TeamStanding? {
        dataService.standings(for: selectedSeason, category: .city).first { $0.team.id == team.id }
    }

    private var regularSeasonMatches: [LeagueMatch] {
        dataService.matches(for: team, season: selectedSeason).inPhase(.regularSeason)
    }

    private var playoffMatches: [LeagueMatch] {
        dataService.matches(for: team, season: selectedSeason).inPhase(.playoffs)
    }

    var body: some View {
        List {
            headerSection

            if let profile {
                TeamRosterSectionView(profile: profile)
            }

            TeamRecordSectionView(standing: standing)

            matchHistorySection(
                title: "Regular Season",
                matches: regularSeasonMatches,
                emptyMessage: "No regular season matches"
            )

            if !playoffMatches.isEmpty {
                matchHistorySection(
                    title: "Championship",
                    matches: playoffMatches,
                    emptyMessage: "Did not qualify for the championship"
                )
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(team.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SeasonPickerBar(
                    season: selectedSeason,
                    onPrevious: selectPreviousSeason,
                    onNext: selectNextSeason
                )
            }
        }
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
                }
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func matchHistorySection(title: String, matches: [LeagueMatch], emptyMessage: String) -> some View {
        Section(title) {
            if matches.isEmpty {
                Text(emptyMessage)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(matches) { match in
                    TeamMatchHistoryRowView(match: match)
                }
            }
        }
    }

    private func selectPreviousSeason() {
        guard let previous = selectedSeason.previous else { return }
        selectedSeason = previous
    }

    private func selectNextSeason() {
        guard let next = selectedSeason.next else { return }
        selectedSeason = next
    }
}

#Preview {
    NavigationStack {
        TeamDetailView(team: PreviewData.team, initialSeason: PreviewData.season)
            .environment(LeagueDataService.shared)
    }
}
