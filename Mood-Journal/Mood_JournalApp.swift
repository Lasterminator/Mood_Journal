//
//  Mood_JournalApp.swift
//  Mood-Journal
//
//  Created by Trinath Sai Subhash Reddy Pittala on 5/15/24.
//

import SwiftUI

@main
struct Mood_JournalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(GlobalData())
        }
    }
}
