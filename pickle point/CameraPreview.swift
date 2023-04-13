//
//  CameraPreview.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/11/23.
//

import Foundation
import SwiftUI
import AVFoundation

class LegacyViewfinder: UIView
{

    // We need to set a type for our layer
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
}

struct Viewfinder: UIViewRepresentable {
    
    var session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        
        let legacyView = LegacyViewfinder()
        PREVIEW : if let previewLayer = legacyView.layer as? AVCaptureVideoPreviewLayer {
            previewLayer.session = session
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.masksToBounds = true
            previewLayer.connection?.videoOrientation = .landscapeRight
        }
        
    
        return legacyView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
       
    }
    
    typealias UIViewType = UIView
    
}

struct CameraPreview: View {
    var session = AVCaptureSession()
    
    var body: some View {
        
        // START Setting configuration properties
        session.beginConfiguration()

        // Get the capture device
        if let frontCameraDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) {

            // Set the capture device
            do {
                try! session.addInput(AVCaptureDeviceInput(device: frontCameraDevice))
            }
            
        }

        // END Setting configuration properties
        session.commitConfiguration()
        
        // Start the AVCapture session
        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }
        
        return Viewfinder(session: session)
    }
    
}
