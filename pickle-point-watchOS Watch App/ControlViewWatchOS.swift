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
    @State private var serverScore = [1, 2]
    @State private var currentServer = 2
    @State private var currentlyTeam1Serving = true
    @State private var currentlyTeam2Serving = false
    @State private var sideout = false
    
    @State private var undoTeam1Score = 0
    @State private var undoTeam2Score = 0
    @State private var undoServerScore = [1, 2]
    @State private var undoCurrentServer = 2
    @State private var undoCurrentlyTeam1Serving = true
    @State private var undoCurrentlyTeam2Serving = false
    @State private var undoSideout = false
    @State private var watchConnected = true
    
    var body: some View {
        
        GeometryReader { rect in
            
            ZStack {
                
                VStack {
                    
                    HStack {
                        if watchAppInstalledOniOSBool() {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(watchIsReachable() ? .green : .gray)
                                
                        } else {
                            Image(systemName: "")
                                .padding(11)
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        
        
                            HStack {
                                Text("\(currentlyTeam1Serving ? team1Score : team2Score)")
                                    .font(.system(size: 70))
                                    .foregroundColor(currentlyTeam1Serving ? .green : .red)
                                
                                Text("-")
                                    .font(.title)
                                
                                Text("\(sideout ? "S" : String(currentServer))")
                                    .font(.system(size: 30))
                                
                                Text("-")
                                    .font(.title)
                                
                                Text("\(currentlyTeam1Serving ? team2Score : team1Score)")
                                    .font(.system(size: 50))
                                    .foregroundColor(currentlyTeam2Serving ? .green : .red)
                                //                            Text("\(viewModelWatch.messageText)")
                                //                                .foregroundColor(.white)
                                //                                .font(.largeTitle)
                            }
                            .onTapGesture(count: 2) {
                                nextServer()
                                print("Team 1 serving: \(currentlyTeam1Serving)")
                                print("Team 2 serving: \(currentlyTeam2Serving)")
                            }
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 1.0).onEnded({ _ in
                                    resetGame()
                                })
                            )
                            
                    }
                    
                    Spacer()
                    
                    
                    HStack {
                        Button {
                            undoPoint()
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                        }
                        
                        Button {
                            saveLastMove()
                            addPoint()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    
                }
                
            }
            .edgesIgnoringSafeArea(.top)
            .onAppear {
                connectAppleWatch()
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
        
        if currentlyTeam1Serving {
            if team1Score != undoTeam1Score || team1Score <= undoTeam1Score {
                team1Score -= 1
            }
            
            if team1Score <= 0 {
                team1Score = 0
            }
        }
        
        if currentlyTeam2Serving {
            if team2Score != undoTeam2Score || team2Score <= undoTeam2Score {
                team2Score -= 1
            }
            
            if team2Score <= 0 {
                team2Score = 0
            }
        }
        
        if currentServer != undoCurrentServer {
            currentServer = undoCurrentServer
            print("DD1")
        }
        
        if currentlyTeam1Serving != undoCurrentlyTeam1Serving {
            currentlyTeam1Serving = undoCurrentlyTeam1Serving
            print("DD2")
        }
        
        if currentlyTeam2Serving != undoCurrentlyTeam2Serving {
            currentlyTeam2Serving = undoCurrentlyTeam2Serving
            print("DD3")
        }
        
        if sideout != undoSideout {
            sideout = undoSideout
            print("DD4")
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
                          
    func connectAppleWatch() {
        if viewModelWatch.session.isCompanionAppInstalled && viewModelWatch.session.isReachable {
            watchConnected = true
        } else {
            viewModelWatch.session.activate()
        }
    }
    
    func watchAppInstalledOniOSBool() -> Bool {
        if viewModelWatch.session.isCompanionAppInstalled {
            print("watchConnectedBoolwatchConnectedBool true")
            return true
        } else {
            return false
        }
    }
    
    func watchIsReachable() -> Bool {
        if viewModelWatch.session.isCompanionAppInstalled && viewModelWatch.session.isReachable {
            return true
        } else {
            return false
        }
    }
                        
    
}

struct ControlViewWatchOS_Previews: PreviewProvider {
    static var previews: some View {
        ControlViewWatchOS()
    }
}
