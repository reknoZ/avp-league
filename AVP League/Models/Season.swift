import Foundation

struct Season: Identifiable, Hashable {
    let year: Int

    var id: Int { year }

    static let availableYears = [2024, 2025, 2026]

    static var current: Season { Season(year: 2026) }

    var previous: Season? {
        guard let index = Self.availableYears.firstIndex(of: year), index > 0 else { return nil }
        return Season(year: Self.availableYears[index - 1])
    }

    var next: Season? {
        guard let index = Self.availableYears.firstIndex(of: year), index < Self.availableYears.count - 1 else { return nil }
        return Season(year: Self.availableYears[index + 1])
    }
}
