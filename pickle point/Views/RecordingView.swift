//
//  RecordingView.swift
//  pickle point
//
//  Created by Ezra Yeoh on 11/11/23.
//

import SwiftUI

struct RecordingView: View {
    
    var cameraModel: CameraModel
    var scoreBoardManager: ScoreBoardManager
    var watchKitManager: WatchKitManager_iOS
    var videoRecorder: ViewRecorder
    
    var body: some View {
        
        ZStack {
            CameraPreview(session: cameraModel.session)
                .ignoresSafeArea(.all, edges: .all)
            
            ScoreBoardView(sbm: scoreBoardManager, viewModelPhone: watchKitManager)
                .ignoresSafeArea(.all, edges: .all)
        }
//        .onReceive(NotificationCenter.default.publisher(for: .startViewRecorder)) { _ in
//            videoRecorder.startRecording(self) { _ in
//                print("videoRecorder: Recording started")
//            }
//        }
        .onReceive(NotificationCenter.default.publisher(for: .stopViewRecorder)) { _ in
            videoRecorder.stop()
                print("videoRecorder: Recording started")
            
        }
        
       
    }
}

struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingView(
            cameraModel: CameraModel(),
            scoreBoardManager: ScoreBoardManager(),
            watchKitManager: WatchKitManager_iOS(), videoRecorder: ViewRecorder()
        )
    }
}
