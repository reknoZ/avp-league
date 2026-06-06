import SwiftUI

struct RootTabView: View {
    @Environment(LeagueDataService.self) private var dataService
    @State private var seasonSelection = SeasonSelectionModel()

    var body: some View {
        TabView {
            ScheduleView(seasonSelection: seasonSelection)
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }

            StandingsView(seasonSelection: seasonSelection)
                .tabItem {
                    Label("Standings", systemImage: "list.number")
                }

            TeamsView(seasonSelection: seasonSelection)
                .tabItem {
                    Label("Teams", systemImage: "person.3")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    RootTabView()
        .environment(LeagueDataService.shared)
}
