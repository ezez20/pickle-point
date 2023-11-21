//
//  MyHostingController.swift
//  pickle point
//
//  Created by Ezra Yeoh on 11/19/23.
//

import SwiftUI

class MyHostingController: UIHostingController<RecordingView> {
    
    var videoRecorder = ViewRecorder()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: RecordingView(cameraModel: CameraModel(), scoreBoardManager: ScoreBoardManager(), watchKitManager: WatchKitManager_iOS(), videoRecorder: ViewRecorder()))
        
    }
    
    
}
