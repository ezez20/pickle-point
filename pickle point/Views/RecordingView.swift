//
//  RecordingView.swift
//  pickle point
//
//  Created by Ezra Yeoh on 11/11/23.
//

import SwiftUI

struct RecordingView: View {
    
    var cameraViewModel: CameraViewModel
    var scoreBoardManager: ScoreBoardManager
    var watchKitManager: WatchKitManager_iOS
    var viewRecorder: ViewRecorder
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack {
                if cameraViewModel.avAuthStatus == .authorized {
                    ScoreBoardVCRep(viewRecoder: viewRecorder, cameraModel: cameraViewModel, scoreBoardManager: scoreBoardManager)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .ignoresSafeArea(.all, edges: .all)
                }
                
                CameraPreviewView(session: cameraViewModel.session)
                    .ignoresSafeArea(.all, edges: .all)

                ScoreBoardView(sbm: scoreBoardManager, viewModelPhone: watchKitManager)
                    .ignoresSafeArea(.all, edges: .all)
                    .opacity(viewRecorder.videoCurrentlySaving || cameraViewModel.videoCurrentlySaving || cameraViewModel.avAuthStatus != .authorized || viewRecorder.phpStatus != .authorized ? 0.2 : 1.0)
                
            }
            .background(.black)
        }
       
    }
}

struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingView(
            cameraViewModel: CameraViewModel(),
            scoreBoardManager: ScoreBoardManager(),
            watchKitManager: WatchKitManager_iOS(), viewRecorder: ViewRecorder()
        )
    }
}
