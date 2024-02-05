//
//  ContentView.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/11/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @StateObject private var cameraViewModel = CameraViewModel()
    @StateObject var scoreBoardManager = ScoreBoardManager()
    @StateObject var watchKitManager = WatchKitManager_iOS()
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
                    RecordingView(cameraViewModel: cameraViewModel, scoreBoardManager: scoreBoardManager, watchKitManager: watchKitManager, viewRecorder: viewRecorder)
                        .ignoresSafeArea(.all, edges: .all)
                    
                    ControlsView(sbm: scoreBoardManager, vmWKM: watchKitManager, cm: cameraViewModel, viewRecorder: viewRecorder, circularViewProgress: circularViewProgress)
                        .ignoresSafeArea(.all, edges: .bottom)
                        .opacity(viewRecorder.videoCurrentlySaving || cameraViewModel.videoCurrentlySaving || cameraViewModel.avAuthStatus != .authorized || viewRecorder.phpStatus != .authorized ? 0.2 : 1.0)
                    
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
                if cameraViewModel.avAuthStatus != .authorized || viewRecorder.phpStatus != .authorized {
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
            cameraViewModel.videoCurrentlySaving = false
            viewRecorder.videoCurrentlySaving = false
            viewRecorder.checkPHPLibraryAuthorization()
            cameraViewModel.checkVideoAudioAuthorizationStatus()
        case .inactive:
            print("scenePhase: inactive")
            cameraViewModel.idleCapture()
            viewRecorder.hardResetViewRecorder(cameraViewModel)
            viewRecorder._exporter?.cancelExport()
            scoreBoardManager.userInactivatedGame()
        case .background:
            print("scenePhase: background")
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
