//
//  ControlView.swift
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
    @ObservedObject var cm: CameraViewModel
    @ObservedObject var viewRecorder: ViewRecorder
    @ObservedObject var circularViewProgress: CircularProgressView
    
    // Alert Variables
    @State private var showCmPlAlert = false
    
    var body: some View {
        
        GeometryReader { geo in
            
            // Apple Watch connect Button
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
                        cm.end_Capture {
                            viewRecorder.stop()
                        }
                        
                    }
                }
            } label: {
                if cm.captureState == .idle && viewRecorder.videoCurrentlySaving != true && cm.videoCurrentlySaving != true  {
                    Image(systemName: "record.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.red)
                    
                } else {
                    if cm.captureState == .capturing || cm.captureState == .start {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
            .position(x: geo.size.width/2, y: geo.size.height - 170)
            
            // CustomProgressView
            if cm.videoCurrentlySaving == true || viewRecorder.videoCurrentlySaving == true {
                CustomProgressView(circularViewProgress: circularViewProgress)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(90))
                    .position(x: geo.size.width/2, y: geo.size.height - 170)
            }
            
            // Game Control Views/HStack
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
            .position(x: geo.size.width/2, y: geo.size.height - 80)
            .foregroundColor(.white)
            .opacity(viewRecorder.videoCurrentlySaving || cm.videoCurrentlySaving ? 0.2 : 1.0)
            .opacity(viewRecorder.videoCurrentlySaving || cm.videoCurrentlySaving || cm.avAuthStatus != .authorized || viewRecorder.phpStatus != .authorized ? 0.2 : 1.0)
            
        }
        .disabled(sbm.sideout ? true : false)
        .disabled(viewRecorder.videoCurrentlySaving || cm.videoCurrentlySaving || cm.avAuthStatus != .authorized || viewRecorder.phpStatus != .authorized ? true : false)
        .shareSheet(show: $shareVideo, items: [url])
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
                viewRecorder.startRenderingVideos(cm.videoURL)
            }
        })
        .onChange(of: viewRecorder.finalVideoURL, perform: { videoURL in
            if videoURL != nil {
                url = videoURL
                videoCurrentlySaving = false
                cm.videoCurrentlySaving = false
                shareVideo.toggle()
            }
        })
        .onChange(of: shareVideo) { sheetShowing in
            // Make url = nil, if sheet is dismissed
            if sheetShowing == false {
                print("onChange: shareVideo FALSE")
//                viewRecorder.deleteFilesInFileManager(cm: cm) 
                viewRecorder.hardResetViewRecorder(cm)
//                viewRecorder.finalVideoURL = nil
                DispatchQueue.main.async {
                    cm.videoURL = nil
                    print("PDEBUG1-2: \(viewRecorder.videoCurrentlySaving)")
                    print("PDEBUG2-2: \(viewRecorder.imageFileURLs.count)")
                    print("PDEBUG3-2: \(viewRecorder.documentsDirectory)")
                    print("PDEBUG4-2: \(cm.videoCurrentlySaving)")
                    print("PDEBUG4-2: \(cm.videoURL)")
                }
                url = nil
                viewRecorder.checkPHPLibraryAuthorization()
                sbm.resetGame { print("Game reset") }
            } else {
                circularViewProgress.customPickleBallViewCount = "L-1 (1)"
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
        .onAppear {
            sbm.timer.invalidate()
            if vmWKM.session.isReachable && vmWKM.session.activationState.rawValue == 2 {
                watchIsReachable = true
            } else {
                watchIsReachable = false
            }
            videoCurrentlySaving = false
            url = nil
        }
        .onReceive(vmWKM.$messageBackToControlView) { message in
            print("Message recieved on iPhone ControlsView: \(message)")
            if message["recordStart"] != nil {
                // To prevent recording before Watch is connected if there was a previous trigger from Apple Watch
                guard watchRecentlyConnected == false else { return }
                
                // Record video toggle
                let message = message["recordStart"] as? Bool ?? false
                sbm.startStopGame { gameStarted in
                    if gameStarted {
                    } else {
                        cm.end_Capture { }
                        viewRecorder.stop()
                    }
                }
                
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
            cm: CameraViewModel(), viewRecorder: ViewRecorder(),
            circularViewProgress: CircularProgressView()
        )
    }
}
