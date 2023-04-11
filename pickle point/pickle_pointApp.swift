//
//  pickle_pointApp.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/11/23.
//

import SwiftUI

@main
struct pickle_pointApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
