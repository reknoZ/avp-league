import SwiftUI

struct TeamRosterSectionView: View {
    let profile: TeamSeasonProfile

    var body: some View {
        Section("Roster") {
            rosterRow(division: "Men's", pair: profile.mensPair)
            rosterRow(division: "Women's", pair: profile.womensPair)
        }
    }

    private func rosterRow(division: String, pair: PlayerPair) -> some View {
        LabeledContent(division, value: pair.display)
    }
}

#Preview {
    Form {
        TeamRosterSectionView(profile: PreviewData.profile)
    }
}
