//
//  AVP_LeagueApp.swift
//  AVP League
//
//  Created by David on 6/6/26.
//

import SwiftUI

@main
struct AVP_LeagueApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var dataService = LeagueDataService.shared

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(dataService)
                .onAppear {
                    dataService.startAutoRefresh()
                }
                .onDisappear {
                    dataService.stopAutoRefresh()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                dataService.startAutoRefresh()
            case .background, .inactive:
                dataService.stopAutoRefresh()
            @unknown default:
                break
            }
        }
    }
}
