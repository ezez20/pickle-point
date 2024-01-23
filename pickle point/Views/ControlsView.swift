//
//  ControlView2.swift
//  pickle point
//
//  Created by Ezra Yeoh on 11/14/23.
//

import SwiftUI

struct ControlsView: View {
    
    //Video variables:
    @State private var url: URL?
    @State private var shareVideo = false
    @State private var videoCurrentlySaving = false
    
    // WatchKit variables:
    @State private var watchIsReachable = false
    @State private var watchRecentlyConnected = false
    
    // Observered Classes
    @ObservedObject var sbm: ScoreBoardManager
    @ObservedObject var vmWKM: WatchKitManager_iOS
    @ObservedObject var cm: CameraModel
    
    @ObservedObject var viewRecorder: ViewRecorder
    
    var body: some View {
        
        GeometryReader { geo in
            
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
            
          
                // Record-Stop video: Button
                Button {
                    // User hits record - video
                    sbm.startStopGame { gameStarted in
                        if gameStarted {
                        } else {
                            cm.end_Capture {}
                        }
                    }
                } label: {
                    if !sbm.gameStart && !videoCurrentlySaving  {
                        Image(systemName: "record.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.red)
                       
                    } else {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .position(x: geo.size.width/2, y: geo.size.height - 170)
            
                
                HStack {
                    // Undo Point: Button
                    Button {
                        sbm.undoPoint()
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
                        sbm.saveLastMove()
                        sbm.addPoint()
                    } label: {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color("neonGreen"))
                            .frame(width: 70, height: 70)
                            .padding(10)
                    }
                    .rotationEffect(.degrees(90))
                    
                    // Next Server: Button
                    Button {
                        sbm.saveLastMove()
                        sbm.nextServer()
                    } label: {
                        ZStack {
                            Text("\(sbm.sideout ? "S" : "\(sbm.currentServer)")")
                                .font(.body)
                                .bold()
                            
                            Image(systemName: "circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(15)
                        }
                        .foregroundColor(.white)
                        .shadow(color: sbm.currentlyTeam1Serving ? .green : .red, radius: 10)
                        .rotationEffect(.degrees(90))
                        
                    }
                }
                .frame(width: 150, height: 120)
                .foregroundColor(.white)
                .opacity(videoCurrentlySaving ? 0.2 : 1.0)
                .disabled(videoCurrentlySaving ? true : false)
                .position(x: geo.size.width/2, y: geo.size.height - 80)

            if videoCurrentlySaving {
                MyView2(viewRecorder: viewRecorder)
                    .frame(width: 60, height: 60)
                    .position(x: geo.size.width/2, y: geo.size.height - 170)
            }
           
        }
        .shareSheet(show: $shareVideo, items: [url])
        .onAppear {
            sbm.timer.invalidate()
            if vmWKM.session.isReachable && vmWKM.session.activationState.rawValue == 2 {
                watchIsReachable = true
            } else {
                watchIsReachable = false
            }
        }
        .onReceive(vmWKM.$messageBackToControlView) { message in
            print("Message recieved on iPhone ControlsView: \(message)")
            if message["recordStart"] != nil {
                // To prevent recording before Watch is connected if there was a previous trigger from Apple Watch
                guard watchRecentlyConnected == false else { return }
                
                // Record video toggle
                let message = message["recordStart"] as? Bool ?? false
                if message == true {
                    sbm.startStopGame { gameStarted in
                        if gameStarted {
                        } else {
                            cm.end_Capture {}
                        }
                    }
                }
//                if message == true {
//                    cm.start_Capture {
//                        sbm.startStopGame { _ in }
//                    }
//                } else {
//                    cm.end_Capture {
//                        sbm.startStopGame() { _ in }
//                    }
//                }
            }
        }
        .onChange(of: cm.videoCurrentlySaving) { videoSaving in
            print("DDD videoCurrentlySaving: \(videoSaving)")
            if videoSaving {
                videoCurrentlySaving = true
                print("DDD: videoCurrentlySaving \(videoCurrentlySaving)")
            }
        }
        .onChange(of: cm.videoURL, perform: { videoURL in
            if videoURL != nil {
                print("CM Video URL: \(String(describing: videoURL))")
                viewRecorder.stop(cm.videoURL)
            }
        })
        .onChange(of: viewRecorder.finalVideoURL, perform: { videoURL in
            if videoURL != nil {
                url = videoURL
//                videoCurrentlySaving = false
                videoCurrentlySaving = false
                cm.videoCurrentlySaving = false
                shareVideo.toggle()
            }
        })
        .onChange(of: shareVideo) { sheetShowing in
            // Make url = nil, if sheet is dismissed
            if sheetShowing == false {
                DispatchQueue.global(qos: .utility).async {
                    do {
                        let fileName1ToDelete = "sbScreenshotsFile.mp4"
                        let fileName1URLToDelete = FileManager.default.temporaryDirectory.appendingPathComponent(fileName1ToDelete)
                        try FileManager.default.removeItem(at: fileName1URLToDelete)
                        print("File: sbScreenshotsFile.mp4 - deleted successfully.")
                        
                        let fileName2ToDelete = "overlayedFinalVideoFile.mp4"
                        let file2URLToDelete = FileManager.default.temporaryDirectory.appendingPathComponent(fileName2ToDelete)
                        try FileManager.default.removeItem(at: file2URLToDelete)
                        print("File: overlayedFinalVideoFile.mp4 - deleted successfully.")
                        
//                        guard cm.videoURL != nil else { return }
                        if let file3NameToDelete = cm.videoURL {
                                try FileManager.default.removeItem(at: file3NameToDelete)
                                print("File: \(file3NameToDelete) - deleted successfully")
                        }
                        
                    } catch {
                        print("Error deleting from FileManager: \(error.localizedDescription)")
                    }
                }
                
//                videoCurrentlySaving = false
//                cm.videoCurrentlySaving = false
                viewRecorder.finalVideoURL = nil
                url = nil
                
                sbm.resetGame {
                    print("Game reset")
                }
            }
        }   
        .onChange(of: vmWKM.session.activationState.rawValue) { activationState in
            print("viewModelPhone activation: \(activationState)")
            if activationState == 2 {
                watchIsReachable = true
            } else {
                watchIsReachable = false
            }
        }

    }
    
}

extension ControlsView {
    
    func connectAppleWatch() {
        print("Connecting to Apple Watch...")
        vmWKM.session.activate()
        watchRecentlyConnected = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            checkWatchConnection()
        }
    }
    
    func checkWatchConnection() {
        if vmWKM.session.activationState.rawValue == 2 && vmWKM.session.isReachable {
            watchIsReachable = true
            print("Apple watch is connected")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                watchRecentlyConnected = false
            }
        } else {
            watchIsReachable = false
            print("Apple watch is NOT connected")
        }
    }
    
}

struct ControlView2_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(
            sbm: ScoreBoardManager(),
            vmWKM: WatchKitManager_iOS(),
            cm: CameraModel(), viewRecorder: ViewRecorder()
        )
    }
}
