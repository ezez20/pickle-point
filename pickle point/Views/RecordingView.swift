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
                
//                MyView(viewRecoder: videoRecorder, cameraModel: cameraModel, scoreBoardManager: scoreBoardManager)
//                    .frame(width: geo.size.width, height: geo.size.height)
//                    .ignoresSafeArea(.all, edges: .all)
                
                CameraPreview(session: cameraModel.session)
                    .ignoresSafeArea(.all, edges: .all)
                
                MyView(viewRecoder: videoRecorder, cameraModel: cameraModel, scoreBoardManager: scoreBoardManager)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea(.all, edges: .all)
                
//                MyView(viewRecoder: videoRecorder, cameraModel: cameraModel, scoreBoardManager: scoreBoardManager)
//                    .frame(width: 80, height: 180)
//                    .position(x: geo.size.width/2, y: geo.size.height/2)
//                    .position(x: geo.size.width - 40, y: 80)
                
//                ScoreBoardView(sbm: scoreBoardManager, viewModelPhone: watchKitManager)
//                    .ignoresSafeArea(.all, edges: .all)
                
//                MyView2()
//                    .ignoresSafeArea(.all, edges: .all)
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
