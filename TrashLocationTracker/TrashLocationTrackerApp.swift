//
//  TrashLocationTrackerApp.swift
//  TrashLocationTracker
//
//  Created by Amit Gupta on 3/20/23.
//

import SwiftUI

@main
struct TrashLocationTrackerApp: App {
    var refreshManager = RefreshManager(refreshTab: 1)
    var body: some Scene {
        WindowGroup {
            MultiTabView()
                .environmentObject(refreshManager)
        }
    }
}
