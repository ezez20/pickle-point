//
//  CameraModel.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/11/23.
//

import Foundation
import SwiftUI
import AVFoundation

//class CameraModel: ObservableObject {
//
//    @Published var session = AVCaptureSession()
//    @Published var alert = false
//    @Published var output = AVCapturePhotoOutput()
//
//    @Published var preview = AVCaptureVideoPreviewLayer()
//
//    func authorizeCamera() {
//
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            // Setting up session
//            setUpCamera()
//
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
//                if granted {
//                    DispatchQueue.main.async {
//                        self?.setUpCamera()
//                    }
//                } else {
//                    return
//                }
//            }
//        case .denied:
//            self.alert.toggle()
//            return
//        default:
//            return
//        }
//
//    }
//
////    func setUpCamera() {
////        let session = AVCaptureSession()
////        do {
////
////            // 1: set configs
////            self.session.beginConfiguration()
////
////            // 2: device
////            guard let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) else { return }
////            guard let input = try? AVCaptureDeviceInput(device: device) else { return }
////
////            // 3: checking if input can be added to session
////            if self.session.canAddInput(input) {
////                self.session.addInput(input)
////            }
////
////            // 4: checking if output can be added to session
////            if self.session.canAddOutput(output) {
////                self.session.addOutput(output)
////            }
////
////
////
////            // 5: Commit session configs
////            session.commitConfiguration()
////            self.session = session
////
////        } catch {
////            print("Error setting up camera \(error.localizedDescription)")
////        }
////
////    }
//    func setUpCamera() {
////        var session = AVCaptureSession()
//
//        session.beginConfiguration()
//
//        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
//            do {
//                let input = try AVCaptureDeviceInput(device: device)
//                if session.canAddInput(input) {
//                    session.addInput(input)
//                }
//
//                if session.canAddOutput(output) {
//                    session.addOutput(output)
//                }
//
//                preview.videoGravity = .resizeAspectFill
//                preview.session = session
//
//                session.commitConfiguration()
//                self.session = session
//
////                DispatchQueue.global(qos: .background).async { [weak self] in
////                    self?.session.startRunning()
////                }
//
//
//
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//    }
//
//}

//class CameraModel: ObservableObject {
//    
////    var session = AVCaptureSession()
//    
//    let output = AVCapturePhotoOutput()
//    let previewLayer = AVCaptureVideoPreviewLayer()
//    var session = AVCaptureSession()
//    
//    func start(completion: @escaping (Error?) -> ()) {
//        checkPermissions(completion: completion)
//    }
//    
//    private func checkPermissions(completion: @escaping (Error?) -> ()) {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
//                guard granted else { return }
//                DispatchQueue.main.async {
//                    self?.setupCamera(completion: completion)
//                    print("permission granted")
//                }
//            }
//        case .restricted:
//            print("permission restricted")
//            break
//        case .denied:
//            print("permission denied")
//            break
//        case .authorized:
//            setupCamera(completion: completion)
//            print("permission granted")
//        @unknown default:
//            print("permission unknown")
//            break
//        }
//    }
//    
//    private func setupCamera(completion: @escaping (Error?) -> ()) {
//       
//        
//        // START Setting configuration properties
//        session.beginConfiguration()
//
//        
//        // Get the capture device
//        DEVICE : if let frontCameraDevice = AVCaptureDevice.default(
//            .builtInWideAngleCamera,
//            for: .video,
//            position: .front
//        ) {
//
//            // Set the capture device
//            do {
//                try! session.addInput(AVCaptureDeviceInput(device: frontCameraDevice))
//            }
//        }
//
//        // END Setting configuration properties
//        session.commitConfiguration()
//
//        // Start the AVCapture session
//        session.startRunning()
//        
//      
//    }
//    
//    
//}
