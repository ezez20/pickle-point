//
//  CameraView.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/11/23.
//

import Foundation
import SwiftUI
import AVFoundation
import CoreData
import WatchConnectivity

struct ControlsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

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
    
    @State var timePassed = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var gameStart = false
    @State private var url: URL?
    @State private var shareVideo = false
    @State private var videoCurrentlySaving = false

    
    @State var reachable = false
    @ObservedObject var viewModelPhone = ViewModelPhone()
    
    var body: some View {
        
        ZStack {
            
            HStack(alignment: .top) {
                
                VStack(alignment: .leading) {
                    
                    Spacer()
        
                    // next point: Button
                    HStack {
                        Button {
                            // next point func
                            saveLastMove()
                            nextServer()
                        } label: {
                            ZStack {
                                Text("\(sideout ? "S" : "\(currentServer)")")
                                    .font(.callout)
                                
                                Image(systemName: "circle")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                            }
                            .padding(EdgeInsets(top: 30, leading: 30, bottom: 30, trailing: 30))
                            .foregroundColor(.white)
                            .shadow(color: .green, radius: 2)
                        }
                        
                        // Record/Stop video: Button
                        Button {
                            // User hits record - video
                            startStopGame()
                            
                        } label: {
                            Image(systemName: "circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(gameStart ? .red : .green)
                        }
                        
                    }
                    
                }
                .foregroundColor(.white)
                
                Spacer()
                Spacer()
                
                VStack {
                    
                    HStack(alignment: .center) {
                        
                        // Add point: Button
                        HStack(spacing: 10) {
                            
                            VStack {
                                Image(systemName: currentlyTeam1Serving ? "soccerball" : "")
                                    .fixedSize()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.green)
                                
                                if currentlyTeam1Serving {
                                    Text("\(sideout ? "" : "\(currentServer)")")
                                        .font(.callout)
                                        .foregroundColor(.white)
                                }
                                
                            }
                            
                            // Undo point: Button
                            Text("\(team1Score)")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .shadow(color: .green, radius: 2)
                            
                        }
                        .foregroundColor(.white)
                        
                        Text("\(convertSecondsToTime(secondsIn: timePassed))")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .shadow(color: .red, radius: 2)
                            .onReceive(timer) { _ in
                                timePassed += 1
                            }
                        
                        
                        HStack(spacing: 10) {
                            
                            Text("\(team2Score)")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .shadow(color: .yellow, radius: 2)
                            
                            VStack {
                                
                                Image(systemName: currentlyTeam2Serving ? "soccerball" : "")
                                    .fixedSize()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(.green)
                                
                                if currentlyTeam2Serving {
                                    Text("\(sideout ? "" : "\(currentServer)")")
                                        .font(.callout)
                                        .foregroundColor(.white)
                                }
                                
                            }
                            
                        }
                        .foregroundColor(.white)
                        
        
                    }
                    .padding(10)
                    
                    Text(sideout ? "Side Out" : "")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 1.0).onEnded({ _ in
                        resetGame()
                    })
                )
                
                Spacer()
                Spacer()
                
                // BUTTONS: right side
                VStack(alignment: .trailing) {
                    
                    Spacer()
                    Spacer()
                    
                    HStack(alignment: .center) {
                        
                        Button {
                            // Connect to WatchOS
                            
//                            viewModelPhone.session.activate()
                            
                            print("Phone debug: \(viewModelPhone.session.activationState)")
                            
                            if viewModelPhone.session.isReachable {
                                reachable = true
                            } else {
                                reachable = false
                            }
                            
                            viewModelPhone.send(message: ["message" : "activated"])
                            
                        } label: {
                            Image(systemName: "applewatch")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(reachable ? .green : .red)
                        }
                        
                        // Undo point: Button
                        Button {
                            undoPoint()
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        .padding(20)
                        
                        // Add point: Button
                        Button() {
                            saveLastMove()
                            addPoint()
                        } label: {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        .padding(20)
                    }
                    .padding(10)
                  
                    
                }
                .foregroundColor(.white)
                
               
            }
            
            if videoCurrentlySaving {
                HStack {
                    Text("Video currently saving")
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .padding(10)
                        .foregroundColor(.white)
                }
                .foregroundColor(.white)
            }

            
        }
        .shareSheet(show: $shareVideo, items: [url])
        .onAppear {
            timer.upstream.connect().cancel()
            
            viewModelPhone.session.activate()
            
            if viewModelPhone.session.isReachable {
                reachable = true
            } else {
                reachable = false
            }
        }
        
    }
    
    
}

extension ControlsView {
    
    func startStopGame() {
        
        gameStart.toggle()
        
        if gameStart {
            startRecording { error in
                
                if error != nil {
                    print("Error on video recording start \(error?.localizedDescription)")
                } else {
                    self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                }
            }
        } else {
            
            //Stop timer
            timer.upstream.connect().cancel()
            timePassed = 0
            videoCurrentlySaving = true
            
            // Stop recording
            Task {
                do {
                    self.url = try await stopRecording()
                    shareVideo.toggle()
                    videoCurrentlySaving = false
                    resetGame()
                } catch {
                    print("Error stopping video recording: \(error.localizedDescription)")
                    videoCurrentlySaving = false
                }
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
    
    
    
    func convertSecondsToTime(secondsIn: Int) -> String {
        
        let minutes = secondsIn / 60
        let seconds = secondsIn % 60
        
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    func fireTimer() {
        print("Timer fired!")
    }
}

struct CameraView_Previews: PreviewProvider {
    
    static var previews: some View {
        ControlsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
    
}
