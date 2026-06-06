import SwiftUI

struct StandingsHeaderView: View {
    var body: some View {
        HStack {
            Text("Ranked by match points (3 for 2-0, 2 for 2-1, 1 for 1-2), then wins, then set differential.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    StandingsHeaderView()
        .padding()
}
