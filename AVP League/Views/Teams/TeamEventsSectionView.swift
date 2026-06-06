import SwiftUI

struct TeamEventsSectionView: View {
    let events: [String]

    var body: some View {
        Section("Regular Season Events") {
            ForEach(events, id: \.self) { event in
                Label(event, systemImage: "calendar")
            }
        }
    }
}

#Preview {
    Form {
        TeamEventsSectionView(events: PreviewData.profile.events)
    }
}
