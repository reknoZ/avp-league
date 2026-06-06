import Foundation

@MainActor
@Observable
final class SeasonSelectionModel {
    var selectedSeason: Season

    init(selectedSeason: Season = Season(year: 2026)) {
        self.selectedSeason = selectedSeason
    }

    func selectPreviousSeason() {
        if let previous = selectedSeason.previous {
            selectedSeason = previous
        }
    }

    func selectNextSeason() {
        if let next = selectedSeason.next {
            selectedSeason = next
        }
    }
}
