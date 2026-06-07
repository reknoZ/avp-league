import SwiftUI

struct ScheduleView: View {
    @Environment(LeagueDataService.self) private var dataService
    @Bindable var seasonSelection: SeasonSelectionModel
    @State private var selectedPhase: SeasonPhase = .regularSeason
    @State private var selectedWeekNumber: Int?

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        return calendar
    }

    private var matches: [LeagueMatch] {
        if seasonSelection.selectedSeason.year == 2026 {
            dataService.season2026Matches
        } else {
            dataService.matches(for: seasonSelection.selectedSeason)
        }
    }

    private var hasPlayoffs: Bool {
        matches.contains { $0.phase == .playoffs }
    }

    private var phaseMatches: [LeagueMatch] {
        matches.inPhase(selectedPhase)
    }

    private var weeks: [ScheduleWeek] {
        ScheduleWeekCalculator.weeks(for: phaseMatches)
    }

    private var selectedWeek: ScheduleWeek? {
        guard selectedPhase == .regularSeason else { return weeks.first }
        guard let selectedWeekNumber else { return weeks.first }
        return weeks.first { $0.number == selectedWeekNumber } ?? weeks.first
    }

    private var selectedWeekIndex: Int? {
        guard let selectedWeek else { return nil }
        return weeks.firstIndex { $0.number == selectedWeek.number }
    }

    private var displayedMatches: [LeagueMatch] {
        switch selectedPhase {
        case .regularSeason:
            guard let selectedWeek else { return phaseMatches }
            return phaseMatches.filter { $0.weekNumber == selectedWeek.number }
        case .playoffs:
            return phaseMatches
        }
    }

    private var liveMatches: [LeagueMatch] {
        displayedMatches
            .filter(\.isLive)
            .sorted { $0.date < $1.date }
    }

    private var selectedWeekVenue: String? {
        displayedMatches.first.map(\.venue)
    }

    private var championshipResults: [ChampionshipFinish] {
        dataService.championshipResults(for: seasonSelection.selectedSeason)
    }

    private var matchesByDay: [(day: Date, matches: [LeagueMatch])] {
        let scheduledMatches = displayedMatches.filter { !$0.isLive }
        let grouped = Dictionary(grouping: scheduledMatches) { match in
            calendar.startOfDay(for: match.date)
        }
        return grouped.keys.sorted().map { day in
            (day, grouped[day]!.sorted { $0.date < $1.date })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Schedule", selection: $selectedPhase) {
                        Text(SeasonPhase.regularSeason.title).tag(SeasonPhase.regularSeason)
                        Text(SeasonPhase.playoffs.title).tag(SeasonPhase.playoffs)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }

                if selectedPhase == .playoffs, !championshipResults.isEmpty {
                    Section("Championship Results") {
                        ChampionshipResultsView(results: championshipResults)
                    }
                }

                if let selectedWeekVenue {
                    Section {
                        Label(VenueTimeZone.weekLocation(from: selectedWeekVenue), systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if displayedMatches.isEmpty {
                    Section {
                        Text(emptyPhaseMessage)
                            .foregroundStyle(.secondary)
                    }
                }

                if !liveMatches.isEmpty {
                    Section {
                        ForEach(liveMatches) { match in
                            LiveMatchRowView(match: match)
                                .listRowBackground(liveRowBackground)
                                .listRowSeparator(.hidden)
                        }
                    }
                }

                ForEach(matchesByDay, id: \.day) { dayGroup in
                    Section {
                        ForEach(dayGroup.matches) { match in
                            ScheduleRowView(match: match)
                        }
                    } header: {
                        Text(MatchDateFormatter.formatDayHeader(dayGroup.day))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SeasonPickerBar(
                        season: seasonSelection.selectedSeason,
                        onPrevious: seasonSelection.selectPreviousSeason,
                        onNext: seasonSelection.selectNextSeason
                    )
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if selectedPhase == .regularSeason, let selectedWeek, let weekIndex = selectedWeekIndex {
                        WeekPickerBar(
                            week: selectedWeek,
                            canGoPrevious: weekIndex > 0,
                            canGoNext: weekIndex < weeks.count - 1,
                            onPrevious: selectPreviousWeek,
                            onNext: selectNextWeek
                        )
                    } else if selectedPhase == .playoffs, let week = weeks.first {
                        Text(week.title)
                            .font(.headline)
                            .padding(.horizontal, 8)
                    }
                }
            }
            .onAppear(perform: resetWeekSelection)
            .onChange(of: seasonSelection.selectedSeason) { _, _ in
                resetWeekSelection()
            }
            .onChange(of: selectedPhase) { _, newPhase in
                if newPhase == .regularSeason {
                    resetWeekSelection()
                }
            }
            .onChange(of: dataService.season2026Matches.count) { _, _ in
                resetWeekSelection()
            }
            .refreshable {
                await dataService.refreshLiveScores()
            }
        }
    }

    private var emptyPhaseMessage: String {
        switch selectedPhase {
        case .regularSeason:
            "No regular season matches scheduled."
        case .playoffs:
            hasPlayoffs
                ? "No championship matches scheduled."
                : "Top \(SeasonStructure.playoffTeamCount) teams after the regular season advance to the championship weekend."
        }
    }

    private func resetWeekSelection() {
        selectedWeekNumber = ScheduleWeekCalculator.defaultWeek(
            in: ScheduleWeekCalculator.weeks(for: matches.inPhase(.regularSeason))
        )?.number
    }

    private func selectPreviousWeek() {
        guard let weekIndex = selectedWeekIndex, weekIndex > 0 else { return }
        selectedWeekNumber = weeks[weekIndex - 1].number
    }

    private func selectNextWeek() {
        guard let weekIndex = selectedWeekIndex, weekIndex < weeks.count - 1 else { return }
        selectedWeekNumber = weeks[weekIndex + 1].number
    }

    private var liveRowBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.red.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.red.opacity(0.35), lineWidth: 1.5)
            )
            .padding(.vertical, 4)
    }
}

#Preview {
    ScheduleView(seasonSelection: SeasonSelectionModel())
        .environment(LeagueDataService.shared)
}
