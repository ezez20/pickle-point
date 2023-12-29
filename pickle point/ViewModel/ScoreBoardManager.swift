//
//  ScoreBoardManager.swift
//  pickle point
//
//  Created by Ezra Yeoh on 11/13/23.
//

import Foundation

class ScoreBoardManager: ObservableObject {

    @Published var team1Score = 0
    @Published var team2Score = 0
    @Published var currentServer = 2
    @Published var currentlyTeam1Serving = true
    @Published var currentlyTeam2Serving = false
    @Published var sideout = false
    
    @Published var undoTeam1Score = 0
    @Published var undoTeam2Score = 0
    @Published var undoCurrentServer = 2
    @Published var undoCurrentlyTeam1Serving = true
    @Published var undoCurrentlyTeam2Serving = false
    @Published var undoSideout = false
    
    @Published var serverLabel = "Server ONE"
    @Published var showServerLabel = false
    @Published var gameResetted = false
    
    @Published var gameStart = false
    @Published var timePassed = 0
    @Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    var timer = Timer()
}

extension ScoreBoardManager {
    
    func startStopGame(completion: @escaping (Bool) -> Void) {
        gameStart.toggle()
        if gameStart {
            //Start timer - Using SwiftUI/Publisher
            self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "startViewRecorder"), object: nil)
            
            // Start timer - Using UIKit
//            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeAppend), userInfo: nil, repeats: true)
            completion(true)
        } else {
            //Stop timer - Using SwiftUI/Publisher
            timer.upstream.connect().cancel()
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "stopViewRecorder"), object: nil)
            
            // Stop timer - Using UIKit
//            timer.invalidate()
            completion(false)
        }
    }
    
    // AppendTimer - Using UIKit
    @objc func timeAppend() {
        print("DDD: timeAppend")
        timePassed += 1
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTimer"), object: nil)
    }
    
    func gameTime(timePassed: Int) -> String {
        let duration = Duration.seconds(timePassed)
        return duration.formatted(.time(pattern: .minuteSecond))
//        let minutes = timePassed / 60
//        let seconds = timePassed % 60
//        let minutesFormatted = minutes > 1 ? minutes : 0
//        return String(format: "%02i:%02i", minutesFormatted, seconds)
    }
    
    func nextServer() {
        // Increment server number.
        currentServer += 1
        
        // If "currentServer ONE or TWO", show "serverLabel".
        if currentServer != 3 {
            if currentServer == 2 {
                serverLabel = "Server TWO"
            } else {
                serverLabel = "Server ONE"
            }
            DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                showServerLabel = true
                print("DDD")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                showServerLabel = false
            }
        }
        
        // If "SideOut", present scoreboard changes.
        if currentServer == 3 {
            showServerLabel = false
            sideout = true
            // To skip to next server.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                // To prevent auto nextServer if user initiated next server themselves.
                if sideout == true {
                    nextServer()
                }
            }
        } else if sideout == true {
            currentServer = 1
            sideout = false
        }
        
        // During "sideout", switch current team serving.
        if sideout == true {
            currentlyTeam1Serving.toggle()
            currentlyTeam2Serving.toggle()
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateVC"), object: nil)
    }
    
    func addPoint() {
        guard sideout == false else { return }
        if currentlyTeam1Serving {
            team1Score += 1
        } else {
            team2Score += 1
        }
        print("Scoreboard Manager team 1 score: \(team1Score)")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "switchImage"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateVC"), object: nil)
    }
    
    func saveLastMove() {
        undoTeam1Score = team1Score
        undoTeam2Score = team2Score
        undoCurrentServer = currentServer
        undoCurrentlyTeam1Serving = currentlyTeam1Serving
        undoCurrentlyTeam2Serving = currentlyTeam2Serving
        undoSideout = sideout
    }
    
    func undoPoint() {
        if sideout == false {
            if currentlyTeam1Serving && currentServer == undoCurrentServer {
                if team1Score >= undoTeam1Score {
                    team1Score -= 1
                }
                
                if team1Score <= 0 {
                    team1Score = 0
                }
            }
            
            if currentlyTeam2Serving && currentServer == undoCurrentServer {
                if team2Score >= undoTeam2Score {
                    team2Score -= 1
                }
                
                if team2Score <= 0 {
                    team2Score = 0
                }
            }
        }
        
        if currentServer != undoCurrentServer {
            currentServer = undoCurrentServer
        }
        
        if currentlyTeam1Serving != undoCurrentlyTeam1Serving {
            currentlyTeam1Serving = undoCurrentlyTeam1Serving
        }
        
        if currentlyTeam2Serving != undoCurrentlyTeam2Serving {
            currentlyTeam2Serving = undoCurrentlyTeam2Serving
        }
        
        if sideout != undoSideout {
            sideout = undoSideout
    
        }
        
        if sideout == true {
            if currentlyTeam1Serving {
                currentlyTeam2Serving = true
                currentlyTeam1Serving = false
            }
            if currentlyTeam2Serving {
                currentlyTeam1Serving = true
                currentlyTeam2Serving = false
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateVC"), object: nil)
    }
    
    func resetGame(completion: @escaping () -> Void) {
        team1Score = 0
        team2Score = 0
        currentServer = 2
        currentlyTeam1Serving = true
        currentlyTeam2Serving = false
        sideout = false
        timePassed = 0
        
        gameResetted = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "resetTimer"), object: nil)
        completion()
        
        // Toggle "Game Reset" banner in ScoreBoardView
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            gameResetted = false
        }
    }
    
}
