//
//  PhoneConnectivity.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/22/23.
//

import Foundation
import WatchConnectivity
import SwiftUI

class ViewModelPhone: NSObject, WCSessionDelegate, ObservableObject {
    
    @Published var session: WCSession
    @Published var messageBackToPhone = [String : Any]()
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        
//        if WCSession.isSupported() {
//            session.activate()
//            print("ViewModelPhone: WCSession activated")
//        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // code
        print("iOS with Watch activationState: \(session.activationState)")
        print("iOS with Watch: \(session.isReachable)")
        print("iOS with Watch: isWatchAppInstalled: \(session.isWatchAppInstalled)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // You must implement this method to support quick switching between Apple Watch devices in your iOS app. The session calls this method when there is no more pending data to deliver to your app and the previous session can be formally closed.
        
        // code
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Tells the delegate that the session will stop communicating with the current Apple Watch.
        
        // code
    }
    
    
    
    
    func send(message: [String : Any]) -> Void {
        session.sendMessage(message, replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
     
        DispatchQueue.main.async {
//            self.messageText = message["message"] as? String ?? "Unknown"
            
            if message["message"] != nil {
                let messsageBack = message["message"] as? [String : Any] ?? [ : ]
                self.messageBackToPhone = messsageBack
                print("messageText: \(messsageBack)")
            }
            
            if message["startRecording"] != nil {
                let messsageBack = message["startRecording"] as? [String : Any] ?? [ : ]
                self.messageBackToPhone = messsageBack
                print("messageText: \(messsageBack)")
            }
            
        }
        
    }
    
    
}
