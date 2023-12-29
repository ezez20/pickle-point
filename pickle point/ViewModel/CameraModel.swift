//
//  CameraModel2.swift
//  pickle point
//
//  Created by Ezra Yeoh on 10/30/23.
//

import AVFoundation
import UIKit

class CameraModel: NSObject, ObservableObject {

    var session = AVCaptureSession()
    private var _videoOutput: AVCaptureVideoDataOutput?
    private var _assetWriter: AVAssetWriter?
    private var _assetWriterVideoInput: AVAssetWriterInput?
    private var _assetWriterAudioInput: AVAssetWriterInput?
    private var _adpater: AVAssetWriterInputPixelBufferAdaptor?
    var _filename = ""
    private var _time: Double = 0
    
    private var _audioOutput: AVCaptureAudioDataOutput?
    
    private enum _CaptureState {
        case idle, start, capturing, end
    }
    private var _captureState = _CaptureState.idle
    
    @Published var videoURL: URL?
    @Published var videoCurrentlySaving = false
    
    private let dispatchQueue = DispatchQueue(label: "com.wyyeoh.pickle-point.video")
    
    override init() {
        super.init()
       checkVideoAudioAuthorizationStatus()
    }
    
    func start_Capture(completion: @escaping () -> (Void)) {
        _captureState = .start
        print("CameraModel: _captureState: start")
        completion()
    }
    
    func end_Capture(completion: @escaping () -> (Void)) {
        _captureState = .end
        print("CameraModel: _captureState: end")
        completion()
    }
    
}

extension CameraModel: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    private func checkVideoAudioAuthorizationStatus() {
        
        print("AVCaptureDevice.authorizationStatus for Video: \(AVCaptureDevice.authorizationStatus(for: .video))")
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("AVCaptureDevice for Video: Request Access granted")
                    self.setupVideo_CaptureSession()
                }
            }
        case .restricted:
            print("restricted")
            break
        case .denied:
            print("denied")
            break
        case .authorized:
            print("authorized")
            setupVideo_CaptureSession()
        @unknown default:
            print("Fatal Error on checking AVCaptureDevice: Video authorizationStatus")
            fatalError()
        }
        
        print("AVCaptureDevice.authorizationStatus for Audio: \(AVCaptureDevice.authorizationStatus(for: .audio))")
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    print("AVCaptureDevice for Audio: Request Access granted")
                    self.setupAudio_CaptureSession()
                }
            }
        case .restricted:
            print("restricted")
            break
        case .denied:
            print("denied")
            break
        case .authorized:
            print("authorized")
            setupAudio_CaptureSession()
        @unknown default:
            print("Fatal Error on checking AVCaptureDevice: Audio authorizationStatus")
            fatalError()
        }
    }
    
    private func setupVideo_CaptureSession() {
        print("Setting up AVCaptureSession")
        session.sessionPreset = .hd1920x1080
        guard let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let cameraInput = try? AVCaptureDeviceInput(device: cameraDevice), session.canAddInput(cameraInput) else { return }
        
        session.beginConfiguration()
        session.addInput(cameraInput)
        session.commitConfiguration()

        let avVideoDataOutput = AVCaptureVideoDataOutput()
        guard session.canAddOutput(avVideoDataOutput) else { return }
        avVideoDataOutput.setSampleBufferDelegate(self, queue: dispatchQueue)
        
        session.beginConfiguration()
        session.addOutput(avVideoDataOutput)
        session.commitConfiguration()
        
        
        dispatchQueue.async {
            self.session.startRunning()
            print("Running AVCaptureSession")
        }
        _videoOutput = avVideoDataOutput
    }
    
    private func setupAudio_CaptureSession() {
        print("Setting up AudioCaptureSession")
        guard let micDevice = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .unspecified), let micInput = try? AVCaptureDeviceInput(device: micDevice), session.canAddInput(micInput) else { return }
        
        session.beginConfiguration()
        session.addInput(micInput)
        session.commitConfiguration()
        
        let avAudioDataOutput = AVCaptureAudioDataOutput()
        guard session.canAddOutput(avAudioDataOutput) else { return }
        avAudioDataOutput.setSampleBufferDelegate(self, queue: dispatchQueue)
        
        session.beginConfiguration()
        session.addOutput(avAudioDataOutput)
        session.commitConfiguration()
        
        
        dispatchQueue.async {
            self.session.startRunning()
            print("Running AVCaptureSession")
        }
        _audioOutput = avAudioDataOutput
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        switch _captureState {
        case .start:
            // Set up Recording
//            _filename = "PickePoint - \(Date.now.formatted(date: .abbreviated, time: .standard))"
            _filename = "PickePoint - \(Date.now.formatted(date: .abbreviated, time: .standard))"
            guard let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(_filename).mov") else { break }
            guard let writer = try? AVAssetWriter(outputURL: videoPath, fileType: .mov) else { break }
            let settings = _videoOutput?.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
            let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings) // [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080])
            videoInput.mediaTimeScale = CMTimeScale(bitPattern: 600)
            videoInput.expectsMediaDataInRealTime = true
            videoInput.transform = CGAffineTransform(rotationAngle: 0)
            let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput, sourcePixelBufferAttributes: nil)
            if writer.canAdd(videoInput) {
                writer.add(videoInput)
            }
            
            let audioSettings = _audioOutput?.recommendedAudioSettingsForAssetWriter(writingTo: .mov)
            let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            audioInput.expectsMediaDataInRealTime = true
            if writer.canAdd(audioInput) {
                writer.add(audioInput)
            }
            
            _assetWriter = writer
            _assetWriterVideoInput = videoInput
            _assetWriterAudioInput = audioInput
            _adpater = adapter
            _time = timestamp
            _captureState = .capturing
            
            writer.startWriting()
            writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            print("DDD: \(sampleBuffer.formatDescription!.mediaType.description)")
            guard sampleBuffer.formatDescription!.mediaType.description == "soun" else { break }
            print("DDD2: \(sampleBuffer.formatDescription!.mediaType.description)")
          
            
        case .capturing:
            // Set up appending Sample Buffer to Input
           
            if output == _videoOutput {
                guard let cmSampleBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { break }
                if _assetWriterVideoInput?.isReadyForMoreMediaData == true {
                    _adpater?.append(cmSampleBuffer, withPresentationTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
                  
                }
            }
            
            if output == _audioOutput {
                if _assetWriterAudioInput?.isReadyForMoreMediaData == true {
                    _assetWriterAudioInput?.append(sampleBuffer)
                }
            }
            break
            
        case .end:
            // Set up ending writer and saving URL
            DispatchQueue.main.async {
                self.videoCurrentlySaving = true
            }
            guard _assetWriterVideoInput?.isReadyForMoreMediaData == true, _assetWriter?.status != .failed else { break }
            guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(_filename).mov") else { break }
            _assetWriterVideoInput?.markAsFinished()
            _assetWriterAudioInput?.markAsFinished()

            _assetWriter?.finishWriting { [weak self] in
                print("_captureState: .idle")
                self?._captureState = .idle
                self?._assetWriter = nil
                self?._assetWriterVideoInput = nil
                self?._assetWriterAudioInput = nil
                DispatchQueue.main.async {
                    self?.videoCurrentlySaving = false
                    self?.videoURL = url
//                    print("Video URL: \(String(describing: url))")
//                    print("URLS existing: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
                }
            }
            
        default:
            break
        }
    }
    
}


