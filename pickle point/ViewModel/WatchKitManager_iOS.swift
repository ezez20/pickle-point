//
//  PhoneConnectivity.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/22/23.
//

import Foundation
import WatchConnectivity
import SwiftUI

class WatchKitManager_iOS: NSObject, WCSessionDelegate, ObservableObject {
    
    @Published var session: WCSession
    @Published var messageBackToControlView = [String : Any]()
    @Published var messageBackToScoreBoardView = [String : Any]()
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("iOS with Watch activationState: \(session.activationState)")
        print("iOS with Watch: \(session.isReachable)")
        print("iOS with Watch: isWatchAppInstalled: \(session.isWatchAppInstalled)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // You must implement this method to support quick switching between Apple Watch devices in your iOS app. The session calls this method when there is no more pending data to deliver to your app and the previous session can be formally closed.
        print("Apple Watch: sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Tells the delegate that the session will stop communicating with the current Apple Watch.
        print("Apple Watch: sessionDidDeactivate")
    }
    
    
    
    func send(message: [String : Any]) -> Void {
        session.sendMessage(message, replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        DispatchQueue.main.async {
            
            if message["message"] != nil {
                let messsageBack = message["message"] as? [String : Any] ?? [ : ]
                self.messageBackToScoreBoardView = messsageBack
                print("messageText: \(messsageBack)")
            }
            
            if message["startRecording"] != nil {
                let messsageBack = message["startRecording"] as? [String : Bool] ?? [ : ]
                self.messageBackToControlView = messsageBack
                print("messageText recording: \(messsageBack)")
            }
            
            if message["getScore"] != nil {
                print("getScore message received")
                NotificationCenter.default.post(name: .reloadScoreForWatch, object: nil)
            }
        }
        
    }
    
    
}

extension Notification.Name {
    static let watchAppActivated = Notification.Name("watchApp.activated")
    static let watchAppDeactivated = Notification.Name("watchApp.deactivated")
    static let reloadScoreForWatch = Notification.Name("reloadScoreForWatch")
    static let startViewRecorder = Notification.Name("startViewRecorder")
    static let updateTimer = Notification.Name("updateTimer")
    static let stopViewRecorder = Notification.Name("stopViewRecorder")
    static let resetTimer = Notification.Name("resetTimer")
    static let updateVC = Notification.Name("updateVC")
    static let testSelector = Notification.Name("testSelector")
}
