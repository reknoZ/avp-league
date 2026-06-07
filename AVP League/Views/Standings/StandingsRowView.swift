import SwiftUI

struct StandingsRowView: View {
    let standing: TeamStanding

    var body: some View {
        HStack(spacing: 10) {
            Text("\(standing.rank)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(standing.rank <= 3 ? .primary : .secondary)
                .frame(width: 16, alignment: .leading)

            Text(standing.team.name)
                .font(.body.weight(.medium))

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(standing.matchPoints) pts")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                Text("\(standing.record) · \(standing.setDifferentialDisplay) sets")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
        .listRowInsets(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 16))
    }
}

#Preview {
    List {
        StandingsRowView(standing: PreviewData.standing)
    }
}
