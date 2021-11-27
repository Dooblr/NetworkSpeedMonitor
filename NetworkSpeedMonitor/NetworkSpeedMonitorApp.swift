//
//  NetworkSpeedMonitorApp.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 11/26/21.
//

import SwiftUI

@main
struct NetworkSpeedMonitorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
