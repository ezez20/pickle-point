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
    @Published var messageFromPhone = [String : Any]()
    @Published var watchIsConnected = false
    @Published var sessionActivation = WCSession.default.activationState.rawValue
    
    init(session: WCSession = .default) {
        print("ViewModelWatch initialized")
      
        self.session = session
        super.init()
        self.session.delegate = self
       
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WatchOS activationState: \(session.activationState)")
        print("WatchOS isCompanionAppInstalled: \(session.isCompanionAppInstalled)")
        if session.isReachable {
            watchIsConnected = true
        } else {
            watchIsConnected = false
        }
    }
    
    
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            watchIsConnected = true
            print("sessionReachabilityDidChange: is reachable")
        } else {
            watchIsConnected = false
            print("sessionReachabilityDidChange: is not reachable")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Watch OS didReceiveMessage")
        DispatchQueue.main.async {
            if message["message"] != nil {
                let messsageBack = message["message"] as? [String : Any] ?? [ : ]
                self.messageFromPhone = messsageBack
                print("messageText: \(messsageBack)")
            }
        }
        if message["getScore"] != nil {
            print("Message from phone: retrieveScore")
        }
    }
    
}
