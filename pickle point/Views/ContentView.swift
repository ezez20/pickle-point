//
//  ContentView.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/11/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @StateObject private var cm = CameraViewModel()
    @StateObject var sbm = ScoreBoardManager()
    @StateObject var wkm = WatchKitManager_iOS()
    @StateObject var viewRecorder = ViewRecorder()
    @StateObject var circularViewProgress = CircularProgressView()
    
    @State private var presentStartupViewBool = false
    @State var userFlow = UserFlow.startup
    
    @State private var showCmPlAlert = false
    
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        Group {
            switch userFlow {
            case .home:
                ZStack {
                    RecordingView(cameraViewModel: cm, scoreBoardManager: sbm, watchKitManager: wkm, viewRecorder: viewRecorder)
                        .ignoresSafeArea(.all, edges: .all)
                    
                    ControlsView(sbm: sbm, vmWKM: wkm, cm: cm, viewRecorder: viewRecorder, circularViewProgress: circularViewProgress)
                        .ignoresSafeArea(.all, edges: .bottom)
                    
                    if showCmPlAlert {
                        VStack(alignment: .center) {
                            Text("Please allow access for Camera, Microphone, and Photo Library.")
                                .foregroundColor(.white)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            
                            Text("This allows PicklePoint to record and save your videos to your camera roll.")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                            
                            Button("Open Settings", role: .none) {  UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) }
                                .foregroundColor(.blue)
                                .padding()
                        }
                        .rotationEffect(.degrees(90))
                    }
                }

            case .startup:
                    StartupLogoView()
                        .ignoresSafeArea(.all)
            case .login:
                VStack {}
            }
            
        }
        .animation(.easeInOut, value: userFlow)// also need Animation
        .transition(.opacity)
        .onChange(of: scenePhase) { scene in
            performOnScene(scene)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                userFlow = .home
                if cm.avAuthStatus != .authorized || viewRecorder.phpStatus != .authorized {
                    showCmPlAlert = true
                } else {
                    showCmPlAlert = false
                }
            }
        }
    }
    
    func performOnScene(_ scenephase: ScenePhase) {
        switch scenephase {
        case .active:
            print("scenePhase: active")
            cm.videoCurrentlySaving = false
            viewRecorder.videoCurrentlySaving = false
            viewRecorder.checkPHPLibraryAuthorization()
            cm.checkVideoAudioAuthorizationStatus()
            print("PDEBUG1: \(viewRecorder.videoCurrentlySaving)")
            print("PDEBUG2: \(viewRecorder.imageFileURLs.count)")
            print("PDEBUG3: \(viewRecorder.documentsDirectory)")
            print("PDEBUG4: \(cm.videoCurrentlySaving)")
            print("PDEBUG4: \(cm.videoURL)")
            print("PDEBUG6: \(viewRecorder.displayLink)")
        case .inactive:
            print("scenePhase: inactive")
        case .background:
            print("scenePhase: background")
            viewRecorder.hardResetViewRecorder(cm)
            print("DDDD: \(viewRecorder.videoCurrentlySaving)")
        @unknown default:
            print("scenePhase: unknown default")
            break
        }
    }

}

enum UserFlow {
    case startup
    case login
    case home
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
