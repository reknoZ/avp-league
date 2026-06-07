import SwiftUI

struct StandingsRowView: View {
    let standing: TeamStanding

    var body: some View {
        HStack(spacing: 12) {
            Text(standing.team.name)
                .font(.body.weight(.medium))

            Spacer()

            StandingsStatColumns(
                wins: standing.genderMatchWins,
                losses: standing.genderMatchLosses,
                points: standing.matchPoints
            )
        }
        .padding(.vertical, 2)
        .listRowInsets(EdgeInsets(top: 11, leading: 16, bottom: 11, trailing: 16))
    }
}

struct StandingsStatColumns: View {
    let wins: Int
    let losses: Int
    let points: Int
    var emphasized = false

    var body: some View {
        HStack(spacing: 0) {
            statCell("\(wins)", width: StandingsStatColumns.columnWidth)
            statCell("\(losses)", width: StandingsStatColumns.columnWidth)
            statCell("\(points)", width: StandingsStatColumns.columnWidth)
        }
        .font(emphasized ? .body.weight(.semibold).monospacedDigit() : .body.monospacedDigit())
    }

    static let columnWidth: CGFloat = 36

    private func statCell(_ value: String, width: CGFloat) -> some View {
        Text(value)
            .frame(width: width, alignment: .trailing)
    }
}

#Preview {
    List {
        StandingsRowView(standing: PreviewData.standing)
    }
}
