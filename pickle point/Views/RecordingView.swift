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
        
        GeometryReader { geo in
            ZStack {
                
                ScoreBoardVCRep(viewRecoder: videoRecorder, cameraModel: cameraModel, scoreBoardManager: scoreBoardManager)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea(.all, edges: .all)
                
                CameraPreview(session: cameraModel.session)
                    .ignoresSafeArea(.all, edges: .all)

                ScoreBoardView(sbm: scoreBoardManager, viewModelPhone: watchKitManager)
                    .ignoresSafeArea(.all, edges: .all)
                
            }
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
