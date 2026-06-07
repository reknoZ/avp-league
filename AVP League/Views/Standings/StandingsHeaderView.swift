import SwiftUI

struct StandingsHeaderView: View {
    let category: StandingsCategory

    var body: some View {
        HStack {
            Text(headerText)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var headerText: String {
        switch category {
        case .city:
            return "Combined men's and women's matches. Ranked by win percentage, then wins, then set differential."
        case .women:
            return "Women's matches only. Ranked by win percentage, then match points, then set differential."
        case .men:
            return "Men's matches only. Ranked by win percentage, then match points, then set differential."
        }
    }
}

#Preview {
    StandingsHeaderView(category: .city)
        .padding()
}
