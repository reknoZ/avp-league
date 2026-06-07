import Foundation

enum StandingsCategory: String, CaseIterable, Identifiable {
    case city
    case women
    case men

    var id: String { rawValue }

    var title: String {
        switch self {
        case .city: "City"
        case .women: "Women"
        case .men: "Men"
        }
    }

    func includes(_ division: GenderDivision) -> Bool {
        switch self {
        case .city: true
        case .women: division == .women
        case .men: division == .men
        }
    }
}
