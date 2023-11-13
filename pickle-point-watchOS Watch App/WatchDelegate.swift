//
//  WatchDelegate.swift
//  pickle-point-watchOS Watch App
//
//  Created by Ezra Yeoh on 11/12/23.
//

import WatchKit
import SwiftUI
import Foundation

class WatchDelegate: NSObject, WKApplicationDelegate, ObservableObject {
    
    func applicationDidBecomeActive() {
        //
        print("applicationDidBecomeActive")
        NSLog("Watch App NOT activated")
        NotificationCenter.default.post(name: .watchAppActivated, object: nil)
    }
    
    func applicationWillEnterForeground() {
        //
        print("applicationWillEnterForeground")
    }
    
    func applicationDidEnterBackground() {
        //
        print("applicationDidEnterBackground")
        NSLog("Watch App activated")
        NotificationCenter.default.post(name: .watchAppDeactivated, object: nil)
    }
    
}

extension Notification.Name {
    static let watchAppActivated = Notification.Name("watchApp.activated")
    static let watchAppDeactivated = Notification.Name("watchApp.deactivated")
    static let reloadScoreForWatch = Notification.Name("reloadScoreForWatch")
}
