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

struct ControlsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @State private var team1Score = 0
    @State private var team2Score = 0
    @State private var serverScore = [1, 2]
    @State private var currentServer = 2
    @State private var currentlyTeam1Serving = true
    @State private var currentlyTeam2Serving = false
    @State private var sideout = false
    
    @State var timePassed = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var gameStart = false
    @State private var url: URL?
    @State private var shareVideo = false
    
    var body: some View {
        
        ZStack {
            
            HStack(alignment: .top) {
                
                VStack(alignment: .leading) {
                    
                    Spacer()
        
                    // next point: Button
                    Button {
                        // next point func
                        nextServer()
                        
                    } label: {
                        ZStack {
                            Image(systemName: "circle")
                                .resizable()
                                .frame(width: 60, height: 60)
                            Text("\(sideout ? "S" : "\(currentServer)")")
                                .font(.largeTitle)
                               
                        }
                    }
                    .padding(10)
                    
                }
                .foregroundColor(.gray)
                
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
                                
                                Text("\(sideout ? "" : "\(currentServer)")")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                
                            }
                            
                            // Undo point: Button
                            Text("\(team1Score)")
                                .font(.largeTitle)
                            
                        }
                        .foregroundColor(.gray)
                        
                        Text("\(convertSecondsToTime(secondsIn: timePassed))")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .padding(20)
                            .onReceive(timer) { _ in
                                timePassed += 1
                            }
                        
                        
                        HStack(spacing: 10) {
                            
                            Text("\(team2Score)")
                                .font(.largeTitle)
                            
                            VStack {
                                
                                Image(systemName: currentlyTeam2Serving ? "soccerball" : "")
                                    .fixedSize()
                                .frame(width: 10, height: 10)
                                
                                Text("\(sideout ? "" : "\(currentServer)")")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                
                            }
                            
                        }
                        .foregroundColor(.gray)
                    }
                    
                    Text(sideout ? "Side Out" : "")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                }
                
                Spacer()
            
                
                // BUTTONS: right side
                VStack(alignment: .trailing) {
                    
                    Spacer()
                    Spacer()
                    
                    // Record/Stop video: Button
                    Button {
                        // User hits record - video
                        startGame()
                        
                    } label: {
                        Image(systemName: "circle")
                            .resizable()
                            .frame(width: 65, height: 65)
                            .foregroundColor(gameStart ? .red : .green)
                    }
                  
                    
                    Spacer()
                    
                    HStack(alignment: .top) {
                        // Undo point: Button
                        Button {
                            undoPoint()
                        } label: {
                            Image(systemName: "arrow.uturn.backward.circle")
                                .resizable()
                                .frame(width: 60, height: 60)
                        }
                        .padding(10)
                        
                        // Add point: Button
                        Button() {
                            addPoint()
                        } label: {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .frame(width: 60, height: 60)
                        }
                        .padding(10)
                    }
                  
                    
                }
                .foregroundColor(.gray)
                
               
            }
            
        }
        .shareSheet(show: $shareVideo, items: [url])
        .onAppear {
            timer.upstream.connect().cancel()
        }
        
    }
    
    
}

extension ControlsView {
    
    func startGame() {
        
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
            
            // Stop recording
            Task {
                do {
                    self.url = try await stopRecording()
                    shareVideo.toggle()

                } catch {
                    print("Error stopping video recording: \(error.localizedDescription)")
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
    
    func undoPoint() {
        
        if sideout == false {
            if currentlyTeam1Serving {
                team1Score -= 1
            } else {
                team2Score -= 1
            }
            
            if team1Score < 0 || team2Score < 0 {
                team1Score = 0
                team2Score = 0
            }
        }
        if sideout == true {
            currentlyTeam1Serving.toggle()
            currentlyTeam2Serving.toggle()
            currentServer = 2
            if currentlyTeam1Serving {
                team1Score -= 1
            } else {
                team2Score -= 1
            }
            sideout = false
        }
        
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
