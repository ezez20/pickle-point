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
    @Published var messageText = ""
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        
//        if WCSession.isSupported() {
//            session.activate()
//            print("ViewModelPhone: WCSession activated")
//        }
    }
    
    func send(message: [String : Any]) -> Void {
        session.sendMessage(message, replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // code
        print("iOS with Watch activationState: \(session.activationState)")
        print("iOS with Watch: \(session.isReachable)")
        print("iOS with Watch: isWatchAppInstalled: \(session.isWatchAppInstalled)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // code
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // code
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
     
        DispatchQueue.main.async {
            self.messageText = message["message"] as? String ?? "Unknown"
            print("messageText: \(self.messageText)")
        }
    }
    
}
