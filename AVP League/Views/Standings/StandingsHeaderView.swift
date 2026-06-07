import SwiftUI

struct StandingsHeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Spacer()

            HStack(spacing: 0) {
                headerCell("W")
                headerCell("L")
                headerCell("Pts")
            }
        }
        .padding(.vertical, 4)
    }

    private func headerCell(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(width: StandingsStatColumns.columnWidth, alignment: .trailing)
    }
}

#Preview {
    StandingsHeaderView()
        .padding()
}
