//
//  ControlViewWatchOS.swift
//  pickle-point-watchOS Watch App
//
//  Created by Ezra Yeoh on 4/21/23.
//

import SwiftUI

struct ControlViewWatchOS: View {
    
    @ObservedObject var viewModelWatch = ViewModelWatch()

    
    @State private var team1Score = 0
    @State private var team2Score = 0
    @State private var currentServer = 2
    @State private var currentlyTeam1Serving = true
    @State private var currentlyTeam2Serving = false
    @State private var sideout = false
    
    @State private var undoTeam1Score = 0
    @State private var undoTeam2Score = 0
    @State private var undoCurrentServer = 2
    @State private var undoCurrentlyTeam1Serving = true
    @State private var undoCurrentlyTeam2Serving = false
    @State private var undoSideout = false
    @State private var watchConnected = false
    @State private var watchSessionOn = false
    @State private var startGameQueue = false
    @State private var gameStart = false

    
    var body: some View {
        
        GeometryReader { rect in
            
            ZStack {
                
                VStack {
                    
                    HStack {
                        
                        if watchSessionOn {
                            Image(systemName: "record.circle")
                                .foregroundColor(gameStart ? .red : .green)
                                .padding()
                                .onTapGesture {
                                    if gameStart == false {
                                        startGameQueue = true
                                    } else {
                                        gameStart = false
                                        // Stop recording
                                        let message = ["recordStart" : false]
                                        viewModelWatch.session.sendMessage(["startRecording" : message], replyHandler: nil)
                                    }
                                }
                        }
                        
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .foregroundColor(watchSessionOn ? .green : .gray)
                            .padding()
                            .onTapGesture {
                                connectAppleWatch()
                            }
                        
                        Spacer()
                    }
                   

                
                    HStack {
                        
                        if startGameQueue {
                            
                            Text("Start Game")
                                .font(.system(size: 20))
                                .fixedSize()
                                .onTapGesture {
                                    let message = ["recordStart" : true]
                                    viewModelWatch.session.sendMessage(["startRecording" : message], replyHandler: nil)
                                    startGameQueue = false
                                    gameStart = true
                                }
                            
                        } else {
                            
                            Text("\(currentlyTeam1Serving ? team1Score : team2Score)")
                                .font(.system(size: 50))
                                .fixedSize()
                                .foregroundColor(currentlyTeam1Serving ? .green : .red)
                            
                            Text("-")
                                .font(.system(size: 20))
                                .fixedSize()
                            
                            Text("\(currentlyTeam1Serving ? team2Score : team1Score)")
                                .font(.system(size: 30))
                                .fixedSize()
                                .foregroundColor(currentlyTeam2Serving ? .green : .red)
                            
                            Text("-")
                                .font(.system(size: 20))
                                .fixedSize()
                            
                            Text("\(sideout ? "S" : String(currentServer))")
                                .font(.system(size: 20))
                                .fixedSize()
                            
                        }
          
                    }
                    .position(CGPoint(x: rect.size.width/2, y: rect.size.height/2 - rect.safeAreaInsets.top*2))
                    .onTapGesture(count: 2) {
                        nextServer()
                        print("Team 1 serving: \(currentlyTeam1Serving)")
                        print("Team 2 serving: \(currentlyTeam2Serving)")
                        
                        updateScoreToPhone()
                    }
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 1.0).onEnded({ _ in
                            resetGame()

                            updateScoreToPhone()
                            
                        })
                        
                    )
                    
                    
                    HStack {
                        Button {
                            undoPoint()
                            
                            updateScoreToPhone()
                            
                            if startGameQueue {
                                startGameQueue = false
                            }
                            
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                        }
                        
                        
                        Button {
                            saveLastMove()
                            addPoint()
                            
                            updateScoreToPhone()
                            
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    .position(CGPoint(x: rect.size.width/2, y: rect.size.height/2 - rect.safeAreaInsets.top*2))
                    
                }
                
            }
            .frame(width: rect.size.width, height: rect.size.height)
            .edgesIgnoringSafeArea(.top)
            .onAppear {
                if viewModelWatch.watchIsConnected {
                    watchSessionOn = true
                } else {
                    watchSessionOn = false
                }
            }
            .onChange(of: viewModelWatch.watchIsConnected) { watchConnection in
                print("onChange")
                if watchConnection {
                    print("watchIsReachable: true")
                    watchSessionOn = true
                } else {
                    print("watchIsReachable: false")
                    watchSessionOn = false
                }

            }
            .onChange(of: viewModelWatch.session.activationState) { sessionActivation in
                print("onChange sessionActivation: \(sessionActivation.rawValue)")
            }
            
        }

    }
    
    
    func nextServer() {
    
        currentServer += 1

        if currentServer == 3 {
            sideout = true
        } else if sideout == true {
            currentServer = 1
            sideout = false
        }
        
        if sideout == true {
            currentlyTeam1Serving.toggle()
            currentlyTeam2Serving.toggle()
        }
        
        
    }
    
    func addPoint() {
        
        guard sideout == false else { return }
        
        if currentlyTeam1Serving {
            team1Score += 1
        } else {
            team2Score += 1
        }
        
    }
    
    func saveLastMove() {
        
        undoTeam1Score = team1Score
        undoTeam2Score = team2Score
        undoCurrentServer = currentServer
        undoCurrentlyTeam1Serving = currentlyTeam1Serving
        undoCurrentlyTeam2Serving = currentlyTeam2Serving
        undoSideout = sideout
        print("undoTeam1Score: \(undoTeam1Score)")
        
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
        
    }
    
    func resetGame() {
        team1Score = 0
        team2Score = 0
        currentServer = 2
        currentlyTeam1Serving = true
        currentlyTeam2Serving = false
        sideout = false
    }

                        
}

extension ControlViewWatchOS {
    
    
    func connectAppleWatch() {
        
        viewModelWatch.session.activate()
        
        if viewModelWatch.session.isCompanionAppInstalled && viewModelWatch.session.isReachable {
            watchSessionOn = true
            
        } else {
            watchConnected = false
            //            viewModelWatch.session.activate()
        }
    }
    
    func watchAppInstalledOniOSBool() -> Bool {
        if viewModelWatch.session.isCompanionAppInstalled {
            print("watchConnectedBoolwatchConnectedBool true")
            return true
        } else {
            print("watchConnectedBoolwatchConnectedBool false")
            return false
        }
    }
    
    func watchIsReachable() -> Bool {
        if viewModelWatch.session.isCompanionAppInstalled && viewModelWatch.session.isReachable && viewModelWatch.session.activationState.rawValue == 2 {
            watchConnected = true
            return true
        } else {
            watchConnected = false
            return false
        }
    }
    
    func updateScoreToPhone() {
        
        if watchIsReachable() {
            
            let messageBack: [String: Any] = [
                "team1Score" : team1Score,
                "team2Score": team2Score,
                "currentServer" : currentServer,
                "currentlyTeam1Serving" : currentlyTeam1Serving,
                "currentlyTeam2Serving" : currentlyTeam2Serving,
                "sideout" : sideout,
                "gameStart" : gameStart
            ]
            
            print("viewModelWatch sent message")
            viewModelWatch.session.sendMessage(["message" : messageBack], replyHandler: nil)
        }
        
    }
    
}
    


struct ControlViewWatchOS_Previews: PreviewProvider {
    static var previews: some View {
        ControlViewWatchOS()
    }
}
