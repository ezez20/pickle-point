//
//  CameraPreview.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/11/23.
//

import Foundation
import SwiftUI
import AVFoundation

class LegacyViewfinder: UIView {
    // We need to set a type for our layer
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
}

struct Viewfinder: UIViewRepresentable {
    
    var session: AVCaptureSession?
    let legacyView = LegacyViewfinder()
    
    func makeUIView(context: Context) -> UIView {
        print("makeUIView")
        if let previewLayer = legacyView.layer as? AVCaptureVideoPreviewLayer {
            previewLayer.session = session
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.masksToBounds = true
        }
        
        return legacyView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        print("updateUIView")
//        guard let previewLayer = legacyView.layer as? AVCaptureVideoPreviewLayer else { return }
//        let view = UIView(frame: UIScreen.main.bounds)
////            let statusBarOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
//        let statusBarOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
//            let videoOrientation: AVCaptureVideoOrientation = statusBarOrientation?.videoOrientation ?? .portrait
//        previewLayer.frame = view.frame
//        previewLayer.connection?.videoOrientation = .portrait
       
    }
    
    typealias UIViewType = UIView
    
}

struct CameraPreview: View {
    
    var session: AVCaptureSession?
    var body: some View {
        return Viewfinder(session: session)
    }
    
}


extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portraitUpsideDown:
            print("portraitUpsideDown")
            return .portraitUpsideDown
        case .landscapeRight:
            print("landscapeRight")
            return .landscapeRight
        case .landscapeLeft:
            print("landscapeLeft")
            return .landscapeLeft
        case .portrait:
            print("portrait")
            return .portrait
        default: return nil
        }
    }
}
