//
//  CameraModel.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/11/23.
//

import Foundation
import SwiftUI
import AVFoundation

class CameraModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @Published var videoFrame: CGImage?
    
    private var userGrantedPermission = false
    private let captureSession = AVCaptureSession()
    
    private let dispatchQueue = DispatchQueue(label: "captureSessionQueue")
    private let context = CIContext()
    
    override init() {
        super.init()
        checkSessionPermission()
   
        dispatchQueue.async { [unowned self] in
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }
    
    func checkSessionPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            userGrantedPermission = true
        case .notDetermined:
            requestSessionPermission()
        default:
            userGrantedPermission = false
        }
    }
    
    
    func requestSessionPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.userGrantedPermission = granted
        }
    }
    
    func setupCaptureSession() {
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        guard userGrantedPermission else { return }
        
        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera,for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)
        
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        DispatchQueue.main.async { [unowned self] in
            self.videoFrame = cgImage
        }
        
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        return cgImage
    }
    
}
