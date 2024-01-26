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
    @Published var undoPointBool = false
    
    @Published var serverLabel = "Server ONE"
    @Published var showServerLabel = false
    @Published var gameResetted = false
    
    @Published var gameStart = false
    @Published var timePassed = 0
    
    //Uncomment Timer if - Using SwiftUI/Publisher
//    @Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var timer = Timer()
    
    var savedMoves = [LastMoveModel]()
    var currentMove = 0
}

extension ScoreBoardManager {
    
    func startStopGame(completion: @escaping (Bool) -> Void) {
        gameStart.toggle()
        if gameStart {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "startViewRecorder"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "startCameraRecorder"), object: nil)
            
            //Start timer - Using SwiftUI/Publisher
//            self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            
            // Start timer - Using UIKit
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeAppend), userInfo: nil, repeats: true)
            print("sbm: Game Started")
            completion(true)
        } else {
            //Stop timer - Using SwiftUI/Publisher
//            timer.upstream.connect().cancel()
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "stopViewRecorder"), object: nil)
            
            // Stop timer - Using UIKit
            timer.invalidate()
            print("sbm: Game Ended")
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
    }
    
    func nextServer() {
        // Increment server number.
        saveLastMove()
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                showServerLabel = false
            }
        }
        
        // If "SideOut", present scoreboard changes.
        if currentServer == 3 {
            print("sideout 1")
            showServerLabel = false
            sideout = true
      
            // To skip to next server.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                // To prevent auto nextServer if user initiated next server themselves.
                if sideout == true {
                    nextServer()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateVC"), object: nil)
                    print("sideout dispatch")
                }
            }
        } else if sideout == true {
            currentServer = 1
            sideout = false
     
            print("sideout 2")
        }
        
        // During "sideout", switch current team serving.
        if sideout == true {
            currentlyTeam1Serving.toggle()
            currentlyTeam2Serving.toggle()
            print("During toggle team1: \(currentlyTeam1Serving)")
            print("During toggle team2: \(currentlyTeam2Serving)")
        
            print("sideout 3")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateVC"), object: nil)
    }
    
    func addPoint() {
        saveLastMove()
        print("Current move: \(currentMove)")
        guard sideout == false else { return }
        if currentlyTeam1Serving {
            team1Score += 1
        } else {
            team2Score += 1
        }
        print("Scoreboard Manager team 1 score: \(team1Score)")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateVC"), object: nil)
    }
    
    func saveLastMove() {
        let modelToSave = LastMoveModel(undoTeam1Score: team1Score, undoTeam2Score: team2Score, undoCurrentServer: currentServer, undoCurrentlyTeam1Serving: currentlyTeam1Serving, undoCurrentlyTeam2Serving: currentlyTeam2Serving, undoSideout: sideout)
        print("LastMoveModel to save: \(modelToSave)")
        savedMoves.append(modelToSave)
        currentMove += 1
    }
    
    func undoPoint() {
        showServerLabel = false
        undoPointBool = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)  {
            self.undoPointBool = false
        }
        
        guard currentMove != 0 else { return }
        currentMove -= 1
        
        team1Score = savedMoves[currentMove].undoTeam1Score
        team2Score = savedMoves[currentMove].undoTeam2Score
        currentServer = savedMoves[currentMove].undoCurrentServer
        currentlyTeam1Serving = savedMoves[currentMove].undoCurrentlyTeam1Serving
        currentlyTeam2Serving = savedMoves[currentMove].undoCurrentlyTeam2Serving
        
        sideout = savedMoves[currentMove].undoSideout
        savedMoves.remove(at: currentMove)
        
        // If during sideout, trigger undoPoint to go back to previous server/team.
        if sideout == true {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.undoPoint()
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
        currentMove = 0
        savedMoves.removeAll()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "resetTimer"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateVC"), object: nil)
        completion()
        
        // Toggle "Game Reset" banner in ScoreBoardView
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            gameResetted = false
        }
    }
    
    func resetScore() {
        saveLastMove()
        
        team1Score = 0
        team2Score = 0
        currentServer = 2
        currentlyTeam1Serving = true
        currentlyTeam2Serving = false
        sideout = false
        
        gameResetted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            gameResetted = false
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateVC"), object: nil)
    }
    
}
