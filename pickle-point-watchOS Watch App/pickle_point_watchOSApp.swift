//
//  pickle_point_watchOSApp.swift
//  pickle-point-watchOS Watch App
//
//  Created by Ezra Yeoh on 4/21/23.
//

import SwiftUI

@main
struct pickle_point_watchOS_Watch_AppApp: App {
    
    @WKApplicationDelegateAdaptor var watchAppDelegate: WatchDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
