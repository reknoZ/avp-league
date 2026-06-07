import SwiftUI

struct TeamRecordSectionView: View {
    let standing: TeamStanding?

    var body: some View {
        if let standing {
            Section("Regular Season Record") {
                LabeledContent("Rank", value: "#\(standing.rank)")
                LabeledContent("Match Points", value: "\(standing.matchPoints)")
                LabeledContent("Gender Matches", value: standing.record)
                LabeledContent("Set Differential", value: standing.setDifferentialDisplay)
            }
        }
    }
}

#Preview {
    Form {
        TeamRecordSectionView(standing: PreviewData.standing)
    }
}
