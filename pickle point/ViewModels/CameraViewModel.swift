//
//  CameraViewModel.swift
//  pickle point
//
//  Created by Ezra Yeoh on 10/30/23.
//

import AVFoundation
import UIKit
import Photos

class CameraViewModel: NSObject, ObservableObject {

    var session = AVCaptureSession()
    private var _videoOutput: AVCaptureVideoDataOutput?
    private var _assetWriter: AVAssetWriter?
    private var _assetWriterVideoInput: AVAssetWriterInput?
    private var _assetWriterAudioInput: AVAssetWriterInput?
    var _adpater: AVAssetWriterInputPixelBufferAdaptor?
    var _filename = ""
    private var _time: Double = 0
    
    private var _audioOutput: AVCaptureAudioDataOutput?
    
    enum CaptureState {
        case idle, start, capturing, end
    }
    
    var captureState = CaptureState.idle
    var videoAuthStatus = AVAuthorizationStatus.notDetermined
    var audiovAuthStatus = AVAuthorizationStatus.notDetermined
    var avAuthStatus = AVAuthorizationStatus.notDetermined
    
    @Published var videoURL: URL?
    @Published var videoCurrentlySaving = false
    
    private let dispatchQueue = DispatchQueue(label: "com.wyyeoh.pickle-point.video")
    
    override init() {
        super.init()
       checkVideoAudioAuthorizationStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(startCameraRecorder), name: NSNotification.Name("startCameraRecorder"), object: nil)
    }
    
    func start_Capture(completion: @escaping () -> (Void)) {
        captureState = .start
        print("CameraModel: _captureState: started")
        completion()
    }
    
    func end_Capture(completion: @escaping () -> (Void)) {
        captureState = .end
        print("CameraModel: _captureState ended")
        completion()
    }
    
    @objc func startCameraRecorder() {
        start_Capture {}
    }
    
}

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func checkVideoAudioAuthorizationStatus() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            print("AVCaptureDevice authorizationStatus for Video: Not determined...requesting access.")
            videoAuthStatus = .notDetermined
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("AVCaptureDevice authorizationStatus for Video: Request Access granted")
                    self.videoAuthStatus = .authorized
                    self.setupVideo_CaptureSession()
                }
            }
            break
        case .restricted:
            print("AVCaptureDevice authorizationStatus for Video: restricted")
            videoAuthStatus = .restricted
            break
        case .denied:
            print("AVCaptureDevice authorizationStatus for Video: denied")
            videoAuthStatus = .denied
            break
        case .authorized:
            print("AVCaptureDevice authorizationStatus for Video: authorized")
            videoAuthStatus = .authorized
            setupVideo_CaptureSession()
        @unknown default:
            print("AVCaptureDevice authorizationStatus for Video: Fatal Error on checking AVCaptureDevice: Video authorizationStatus")
            fatalError()
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            print("AVCaptureDevice authorizationStatus for Audio: Not determined...requesting access.")
            audiovAuthStatus = .notDetermined
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    print("AVCaptureDevice.authorizationStatus for Audio: AVCaptureDevice for Audio: Request Access granted")
                    self.audiovAuthStatus = .authorized
                    self.setupAudio_CaptureSession()
                }
            }
            break
        case .restricted:
            print("AVCaptureDevice.authorizationStatus for Audio: restricted")
            audiovAuthStatus = .restricted
            break
        case .denied:
            print("AVCaptureDevice.authorizationStatus for Audio: denied")
            audiovAuthStatus = .denied
            break
        case .authorized:
            print("AVCaptureDevice.authorizationStatus for Audio: authorized")
            audiovAuthStatus = .authorized
            setupAudio_CaptureSession()
        @unknown default:
            print("AVCaptureDevice.authorizationStatus for Audio: Fatal Error on checking AVCaptureDevice: Audio authorizationStatus")
            fatalError()
        }
        
        if videoAuthStatus == .authorized && audiovAuthStatus == .authorized {
            avAuthStatus = .authorized
        } else {
            avAuthStatus = .denied
        }
    }
    
    private func setupVideo_CaptureSession() {
        print("Setting up video_CaptureSession")
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
        print("Setting up audio_CaptureSession")
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
        switch captureState {
        case .start:
            // VIDEO: Setting up AVAssetWriter for writting of input/output
            _filename = "PickePoint - \(UUID().uuidString)"
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
            
            // AUDIO: Setting up AVAssetWriter for writting of input/output
            let audioSettings = _audioOutput?.recommendedAudioSettingsForAssetWriter(writingTo: .mov)
            let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            audioInput.expectsMediaDataInRealTime = true
            if writer.canAdd(audioInput) {
                writer.add(audioInput)
              
            }
            
            // ASSIGNING AVAssetWriter,AVAssetWriterInputPixelBufferAdaptor, CMSampleBufferGetPresentationTimeStamp, and _captureState variables.
            _assetWriter = writer
            _assetWriterVideoInput = videoInput
            _assetWriterAudioInput = audioInput
            _adpater = adapter
            _time = timestamp
            captureState = .capturing
            
            // AVAssetWriter: Start WRITING/SESSION
            let recordingTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            let startTimeDelay = CMTimeMakeWithSeconds(0.3, preferredTimescale: 1000000000)
            let startTimeToUse = CMTimeAdd(recordingTime, startTimeDelay)
            writer.startWriting()
            writer.startSession(atSourceTime: startTimeToUse)
        case .capturing:
            // VIDEO: setup for capturing sampleBuffer
            if output == _videoOutput {
                guard let cmSampleBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { break }
                if _assetWriterVideoInput?.isReadyForMoreMediaData == true {
                    _adpater?.append(cmSampleBuffer, withPresentationTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
                }
            }
            // AUDIO: setup for capturing sampleBuffer
            if output == _audioOutput {
                if _assetWriterAudioInput?.isReadyForMoreMediaData == true {
                    _assetWriterAudioInput?.append(sampleBuffer)
                }
            }
            break
            
        case .end:
            DispatchQueue.main.async {
                self.videoCurrentlySaving = true
            }
            guard _assetWriterVideoInput?.isReadyForMoreMediaData == true, _assetWriter?.status != .failed else { break }
            guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(_filename).mov") else { break }
            _assetWriterVideoInput?.markAsFinished()
            _assetWriterAudioInput?.markAsFinished()

            _assetWriter?.finishWriting { [weak self] in
                print("_captureState: .idle")
                self?.captureState = .idle
                self?._assetWriter = nil
                self?._assetWriterVideoInput = nil
                self?._assetWriterAudioInput = nil
                
                DispatchQueue.main.async {
                    self?.videoURL = url
                }
            }
            
        default:
            break
        }
    }
    
    func idleCapture() {
        self.videoCurrentlySaving = false
        self.captureState = .idle
        self._assetWriter = nil
        self._assetWriterVideoInput = nil
        self._assetWriterAudioInput = nil
        self.videoURL = nil
    }
    
}


