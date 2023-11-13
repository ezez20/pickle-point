//
//  RecordingView.swift
//  pickle point
//
//  Created by Ezra Yeoh on 11/11/23.
//

import SwiftUI

struct RecordingView: View {
    
    var cameraModel: CameraModel
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraModel.session)
                .ignoresSafeArea(.all, edges: .all)
        }
    }
}

struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingView(cameraModel: CameraModel())
    }
}
