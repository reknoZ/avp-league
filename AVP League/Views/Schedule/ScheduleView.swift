import SwiftUI

struct ScheduleView: View {
    @Environment(LeagueDataService.self) private var dataService
    @Bindable var seasonSelection: SeasonSelectionModel
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

    private var weeks: [ScheduleWeek] {
        ScheduleWeekCalculator.weeks(for: matches)
    }

    private var selectedWeek: ScheduleWeek? {
        guard let selectedWeekNumber else { return weeks.first }
        return weeks.first { $0.number == selectedWeekNumber } ?? weeks.first
    }

    private var selectedWeekIndex: Int? {
        guard let selectedWeek else { return nil }
        return weeks.firstIndex { $0.number == selectedWeek.number }
    }

    private var displayedMatches: [LeagueMatch] {
        guard let selectedWeek else { return matches }
        return matches.filter { $0.weekNumber == selectedWeek.number }
    }

    private var liveMatches: [LeagueMatch] {
        displayedMatches
            .filter(\.isLive)
            .sorted { $0.date < $1.date }
    }

    private var selectedWeekVenue: String? {
        displayedMatches.first.map(\.venue)
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
                if let selectedWeekVenue {
                    Section {
                        Label(VenueTimeZone.weekLocation(from: selectedWeekVenue), systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
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
                    if let selectedWeek, let weekIndex = selectedWeekIndex {
                        WeekPickerBar(
                            week: selectedWeek,
                            canGoPrevious: weekIndex > 0,
                            canGoNext: weekIndex < weeks.count - 1,
                            onPrevious: selectPreviousWeek,
                            onNext: selectNextWeek
                        )
                    }
                }
            }
            .onAppear(perform: resetWeekSelection)
            .onChange(of: seasonSelection.selectedSeason) { _, _ in
                resetWeekSelection()
            }
            .onChange(of: dataService.season2026Matches.count) { _, _ in
                resetWeekSelection()
            }
            .refreshable {
                await dataService.refreshLiveScores()
            }
        }
    }

    private func resetWeekSelection() {
        selectedWeekNumber = ScheduleWeekCalculator.defaultWeek(in: weeks)?.number
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
