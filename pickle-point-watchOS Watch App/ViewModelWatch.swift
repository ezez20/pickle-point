//
//  ViewModelWatch.swift
//  pickle-point-watchOS Watch App
//
//  Created by Ezra Yeoh on 4/22/23.
//

import Foundation
import WatchConnectivity
import UIKit

class ViewModelWatch : NSObject, WCSessionDelegate, ObservableObject {
    
    var session: WCSession
    @Published var messageText = ""
    
    init(session: WCSession = .default) {
        print("ViewModelWatch initialized")
      
        self.session = session
        super.init()
        self.session.delegate = self
        
        if WCSession.isSupported() {
            session.activate()
        }
       
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WatchOS activationState: \(session.activationState)")
        print("WatchOS isReachable: \(session.isReachable)")
        print("WatchOS isCompanionAppInstalled: \(session.isCompanionAppInstalled)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.messageText = message["message"] as? String ?? "Unknown"
        }
    }
    
    
    
}
