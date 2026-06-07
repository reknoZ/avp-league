import SwiftUI

struct ChampionshipResultsView: View {
    let results: [ChampionshipFinish]

    var body: some View {
        ForEach(results) { finish in
            HStack(spacing: 12) {
                Text(finish.label)
                    .font(finish.place == 1 ? .subheadline.weight(.semibold) : .subheadline)
                    .foregroundStyle(finish.place == 1 ? .orange : .secondary)
                    .frame(width: 88, alignment: .leading)

                Text(finish.team.name)
                    .font(finish.place == 1 ? .body.weight(.semibold) : .body)

                Spacer()
            }
            .padding(.vertical, 2)
        }
    }
}

#Preview {
    List {
        Section("Championship Results") {
            ChampionshipResultsView(results: [
                ChampionshipFinish(place: 1, teamID: "sds"),
                ChampionshipFinish(place: 2, teamID: "dd"),
                ChampionshipFinish(place: 3, teamID: "mm"),
                ChampionshipFinish(place: 4, teamID: "nyn"),
            ])
        }
    }
}
