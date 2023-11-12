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
    var cameraModel: CameraModel
    
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
    
    @State var timePassed = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var gameStart = false
    @State private var url: URL?
    @State private var shareVideo = false
    @State private var videoCurrentlySaving = false
    @State private var watchRecentlyConnected = false
    
    @State private var serverLabel = "Server ONE"
    @State private var showServerLabel = false
    
    @State var watchIsReachable = false
    @ObservedObject var viewModelPhone = ViewModelPhone()
    
    var body: some View {
        
        GeometryReader { geo in
            
            ZStack {
                
                Text("\(gameTime(timePassed: timePassed))")
                    .rotationEffect(.degrees(90))
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .shadow(color: .yellow, radius: 10)
                    .position(x: geo.size.width - 20, y: geo.size.height/2)
                    .onReceive(timer) { _ in
                        timePassed += 1
                    }
                
                Text(sideout ? "Side Out" : "")
                    .font(.title)
                    .foregroundColor(.white)
                    .shadow(color: .green, radius: 10)
                    .rotationEffect(.degrees(90))
                    .position(x: geo.size.width - 50, y: geo.size.height/2)
                
                Text(showServerLabel ? serverLabel : "")
                    .font(.title)
                    .foregroundColor(.white)
                    .shadow(color: currentlyTeam1Serving ? .green : .red, radius: 10)
                    .rotationEffect(.degrees(90))
                    .position(x: geo.size.width - 50, y: geo.size.height/2)
                
                VStack(alignment: .center, spacing: 5) {
                    
                    Text("\(currentlyTeam1Serving ? team1Score : team2Score)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .shadow(color: currentlyTeam1Serving ? .green : .red, radius: 10)
                        .rotationEffect(.degrees(90))
                    
                    Text("\(currentlyTeam2Serving ? team1Score : team2Score)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .shadow(color: currentlyTeam2Serving ? .green : .red, radius: 10)
                        .rotationEffect(.degrees(90))
                    
                    VStack {
                        Image(systemName: "soccerball")
                            .fixedSize()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.green)
                            .rotationEffect(.degrees(90))
                        
                        Text("\(sideout ? "S" : "\(currentServer)")")
                            .font(.headline)
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(90))
                    }
                    .padding(10)
                    
                }
                .frame(width: 50, height: 180)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .position(x: geo.size.width - 30, y: 100)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 1.0).onEnded({ _ in
                        resetGame()
                    })
                )
                
                Button {
                    // Connect to WatchOS
                    print("Apple Watch button pressed")
                    connectAppleWatch()
                } label: {
                    Image(systemName: watchIsReachable ? "applewatch.watchface" : "applewatch")
                        .resizable()
                        .frame(width: 20, height: 25)
                        .foregroundColor(watchIsReachable ? .green : .red)
                        .padding(20)
                        .rotationEffect(.degrees(90))
                }
                .frame(width: 80, height: 250)
                .position(x: geo.size.width - 30, y: 220)
                
          
                VStack(spacing: 10) {
                    // Record-Stop video: Button
                    Button {
                        // User hits record - video
                        startStopGame()
                    } label: {
                        Image(systemName: "record.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(gameStart ? .red : .green)
                    }
                    
                    HStack {
                        // Undo Point: Button
                        Button {
                            undoPoint()
                        } label: {
                            Image(systemName: "arrow.uturn.backward.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(90))
                                .foregroundColor(.yellow)
                                .padding(15)
                        }
                      
                        // Add point: Button
                        Button() {
                            saveLastMove()
                            addPoint()
                        } label: {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color("neonGreen"))
                                .frame(width: 80, height: 80)
                                .padding(10)
                        }
                        .rotationEffect(.degrees(90))
                    
                        // Next Server: Button
                        Button {
                            saveLastMove()
                            nextServer()
                        } label: {
                            ZStack {
                                Text("\(sideout ? "S" : "\(currentServer)")")
                                    .font(.body)
                                    .bold()
                                
                                Image(systemName: "circle")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .padding(15)
                            }
                            .foregroundColor(.white)
                            .shadow(color: currentlyTeam1Serving ? .green : .red, radius: 10)
                            .rotationEffect(.degrees(90))
                            
                        }
                    }
                }
                .frame(width: 150, height: 120)
                .foregroundColor(.white)
                .position(x: geo.size.width/2, y: geo.size.height - 120)
                
                
                if videoCurrentlySaving {
                    VStack {
                        Text("Video currently saving")
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                            .padding(10)
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(90))
                    }
                    .foregroundColor(.white)
                }
            
            }
            .shareSheet(show: $shareVideo, items: [url])
            .onAppear {
                timer.upstream.connect().cancel()
                if viewModelPhone.session.isReachable {
                    watchIsReachable = true
                } else {
                    watchIsReachable = false
                }
            }
            .onReceive(viewModelPhone.$messageBackToPhone) { message in
                print("Message recieved on iphone ControlsView")
                // If message recieved from watch has value "recordStart", start recording.
                if message["recordStart"] != nil {
                    let message = message["recordStart"] as? Bool ?? false

                    print("DDDD")
                    guard watchRecentlyConnected == false else { return }
                
                    if message == true {
                        startStopGame()
                    } else {
                        startStopGame()
                    }
                    
                // Else, just receive score updates messages from watch.
                } else {
                    updateMessageBackFromWatch(message: message)
                }
            }
            .onChange(of: viewModelPhone.session.activationState.rawValue) { activationState in
                print("viewModelPhone activation: \(activationState)")
                if activationState == 2 {
                    sendMessageToPhone()
                }
            }
            .onChange(of: cameraModel.videoCurrentlySaving) { videoSaving in
                if videoSaving {
                    videoCurrentlySaving = true
                } else {
                    videoCurrentlySaving = false
                }
            }
            .onChange(of: cameraModel.videoURL) { videoURL in
                if videoURL != nil {
                    url = videoURL
                    shareVideo.toggle()
                }
            }
            .onChange(of: shareVideo) { sheetShowing in
                // Make url = nil, if sheet is dismissed
                if sheetShowing == false {
                    url = nil
                }
            }
            .onChange(of: [currentlyTeam1Serving, currentlyTeam2Serving, sideout, gameStart]) { _ in
                sendMessageToPhone()
            }
            .onChange(of: [team1Score, team2Score, currentServer]) { _ in
                sendMessageToPhone()
            }
        }
        
    }
    
}

extension ControlsView {
    
    func startStopGame() {
        gameStart.toggle()
        if gameStart {
            
            cameraModel.start_Capture() { startedRecording in
                if startedRecording {
                    self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                }
            }
            
        } else {
            //Stop timer
            timer.upstream.connect().cancel()
         
            resetGame()
            cameraModel.end_Capture()
        }
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
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                showServerLabel = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showServerLabel = false
            }
        }
        
        // If "SideOut", present scoreboard changes.
        if currentServer == 3 {
            showServerLabel = false
            sideout = true
            // To skip to next server.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
        timePassed = 0
        team1Score = 0
        team2Score = 0
        currentServer = 2
        currentlyTeam1Serving = true
        currentlyTeam2Serving = false
        sideout = false
    }
    
    func gameTime(timePassed: Int) -> String {
        let minutes = timePassed / 60
        let seconds = timePassed % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    func fireTimer() {
        print("Timer fired!")
    }
    
    func connectAppleWatch() {
        print("Connecting to Apple Watch...")
        viewModelPhone.session.activate()
        watchRecentlyConnected = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            checkWatchConnection()
        }
    }
    
    func checkWatchConnection() {
        if viewModelPhone.session.activationState.rawValue == 2 && viewModelPhone.session.isReachable {
            watchIsReachable = true
            sendMessageToPhone()
            print("Apple watch is connected")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                watchRecentlyConnected = false
            }
        } else {
            watchIsReachable = false
            print("Apple watch is NOT connected")
        }
    }
    
    func updateMessageBackFromWatch(message: [String : Any]) {
        if viewModelPhone.session.isReachable {
            print("updateMessageBackFromWatch")
            // If "side out", this will trigger the "side out" switch.
            let currentServerBack = message["currentServer"] as? Int ?? 2
            guard currentServerBack != 3 else {
                nextServer()
                return
            }
            currentServer = currentServerBack
            
            team1Score = message["team1Score"] as? Int ?? 0
            team2Score = message["team2Score"] as? Int ?? 0

            currentlyTeam1Serving = message["currentlyTeam1Serving"] as? Bool ?? true
            currentlyTeam2Serving = message["currentlyTeam2Serving"] as? Bool ?? false
            gameStart = message["gameStart"] as? Bool ?? false
        }
    }
    
    func sendMessageToPhone() {
        let messageBack: [String: Any] = [
            "team1Score" : team1Score,
            "team2Score": team2Score,
            "currentServer" : currentServer,
            "currentlyTeam1Serving" : currentlyTeam1Serving,
            "currentlyTeam2Serving" : currentlyTeam2Serving,
            "sideout" : sideout,
            "gameStart" : gameStart
        ]
        viewModelPhone.session.sendMessage(["message" : messageBack], replyHandler: nil)
    }
    
}

struct CameraView_Previews: PreviewProvider {
    
    static var previews: some View {
        ControlsView(cameraModel: CameraModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
    
}
