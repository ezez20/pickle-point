//
//  ViewRecorder.swift
//  pickle point
//
//  Created by Ezra Yeoh on 11/20/23.
//

import Foundation
import UIKit
import AVFoundation
import CoreMedia
import SwiftUI
import Photos


final class ViewRecorder: NSObject, ObservableObject {
    
    var imageFileURLs = [URL]()
    var actualFPSArray = [Double]()
    var displayLink: CADisplayLink?
    var sourceView: UIView?
    var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var fileURLDirectory: URL?
    var timer = Timer()
    var _exporter: AVAssetExportSession?
    
    var phpStatus = PHAuthorizationStatus.notDetermined
    
    
    @Published var finalVideoURL: URL?
    @Published var videoCurrentlySaving = false
    
    init(imageFileURLs: [URL] = [URL](), actualFPSArray: [Double] = [Double](), displayLink: CADisplayLink? = nil, sourceView: UIView? = nil, documentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!, fileURLDirectory: URL? = nil, timer: Timer = Timer(), _exporter: AVAssetExportSession? = nil, phpStatus: PHAuthorizationStatus = PHAuthorizationStatus.notDetermined, finalVideoURL: URL? = nil, videoCurrentlySaving: Bool = false) {
        self.imageFileURLs = imageFileURLs
        self.actualFPSArray = actualFPSArray
        self.displayLink = displayLink
        self.sourceView = sourceView
        self.documentsDirectory = documentsDirectory
        self.fileURLDirectory = fileURLDirectory
        self.timer = timer
        self._exporter = _exporter
        self.phpStatus = phpStatus
        self.finalVideoURL = finalVideoURL
        self.videoCurrentlySaving = videoCurrentlySaving
        
    }
    
    deinit {
       
        self.displayLink?.remove(from: RunLoop.main, forMode: .default)
        
        displayLink?.invalidate()
        displayLink = nil
        
    }
    
    func requestPHPLibraryAuthorization() {
        PHPhotoLibrary.requestAuthorization({ [self] status in
            switch status {
            case .notDetermined:
                print("PHPhotoLibrary notDetermined")
                phpStatus = .notDetermined
            case .denied:
                print("PHPhotoLibrary denied")
                phpStatus = .denied
            case .restricted:
                print("PHPhotoLibrary restricted")
                phpStatus = .restricted
            case .authorized:
                print("PHPhotoLibrary authorized")
                phpStatus = .authorized
            case .limited:
                print("PHPhotoLibrary limited")
                phpStatus = .limited
            @unknown default:
                fatalError("PHPhotoLibrary::execute - \"Unknown case\"")
            }
        })
    }
    
    func checkPHPLibraryAuthorization() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        phpStatus = status
        print("PHP STATUS: \(status)")
        if phpStatus == .denied || phpStatus == .notDetermined {
            requestPHPLibraryAuthorization()
        }
    
//            if displayLink == nil {
//                displayLink = CADisplayLink(target: self, selector: #selector(tick))
//                displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 30)
//                displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
//            } else {
//                displayLink?.isPaused = false
//              }
//        
//       
//        self.fileURLDirectory = documentsDirectory.appendingPathComponent("screenshotImages")
//        if let url = fileURLDirectory {
//            do {
//                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
//            } catch {
//                print("Error creating directory: \(error)")
//            }
//        }
        
    }
    

    func startRecording(controller: ScoreBoardVC2, completion: @escaping () -> Void) {
        
//        checkPHPLibraryAuthorization()
//        guard phpStatus == .authorized else { return }
        self.sourceView = controller.view
    
//        displayLink = CADisplayLink(target: self, selector: #selector(tick))
//        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 30)
        
//        DispatchQueue.main.async {
//            self.displayLink?.add(to: RunLoop.main, forMode: .default)
//        }
        
        print("RDEBUG 1: \(displayLink)")
        print("RDEBUG 2: \(fileURLDirectory)")
        
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(tick))
            displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 30)
       
                self.displayLink?.add(to: RunLoop.main, forMode: .default)
            
        } else {
            displayLink?.isPaused = false
          }
    
   
    self.fileURLDirectory = documentsDirectory.appendingPathComponent("screenshotImages")
    if let url = fileURLDirectory {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error)")
        }
    }

   
            self.displayLink?.isPaused = false
        
//        DispatchQueue.global(qos: .userInteractive).async {
//                self.displayLink?.add(to: RunLoop.main, forMode: .common)
//        }
        completion()
    }

    func stop() {
        print("videoRecorder: Stopped Recording")
      
//            displayLink?.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
      
//            self.displayLink?.isPaused = true
        
     
            self.displayLink?.isPaused = true
        
   
//        displayLink?.invalidate()
//        displayLink = nil
        
//        DispatchQueue.main.async {
//        
//            self.displayLink?.remove(from: RunLoop.main, forMode: RunLoop.Mode.default)
//        }
//        }


    }
    
    func startRenderingVideos(_ cameraVideoURL: URL?) {
        print("videoRecorder: Start Rendering Video")
        
        guard let cameraVideoURL = cameraVideoURL else {
            print("cameraVideoURL nil")
            return
        }
        
        writeToVideo() { url in
            Task {
                do {
                    if let urlToDelete = self.fileURLDirectory {
                        try FileManager.default.removeItem(at: urlToDelete)
                    }
                    guard let url = url else { return }
                    try await self.overlayVideos(videoURL1: url, videoURL2: cameraVideoURL)
                } catch {
                  print("Error for writeToVideo func: \(error)")
                }
            }
        }
    }

    @objc private func tick(_ displayLink: CADisplayLink) {
        if let sourceView = sourceView {
            let render = UIGraphicsImageRenderer(size: sourceView.frame.size)
            let image = render.image { (ctx) in
                // Adjust sharpness of rendered image
//                sourceView.layer.contentsScale = 2.0
//                sourceView.layer.shouldRasterize = true
//                sourceView.layer.minificationFilter = .nearest
//                sourceView.layer.rasterizationScale = UIScreen.main.scale
                sourceView.layer.render(in: ctx.cgContext)
            }
            let actualFramesPerSecond = 1 / (displayLink.targetTimestamp - displayLink.timestamp)
            print("actualFramesPerSecond: \(actualFramesPerSecond)")
            
            DispatchQueue.global(qos: .default).async { [self] in
                if let imageData = image.pngData() {
                    let imageUrlID = "imageID\(UUID().uuidString)"
                    if let url = fileURLDirectory {
                        let imageURLPATH = url.appendingPathComponent(imageUrlID).appendingPathExtension("png")
                        do {
                            //                        print("CADisplayLink interval: \(displayLink.frameInterval)")
                            try imageData.write(to: imageURLPATH)
                            imageFileURLs.append(imageURLPATH)
                            actualFPSArray.append(actualFramesPerSecond)
                            print("Writing image")
                            print("Writing image ImageFileURL: \(imageURLPATH)")
                        } catch {
                            print("Error imageData.write(to: fileURL)")
                        }
                    }
                }
            }
        }
    }

    private func writeToVideo(completion: @escaping (URL?) -> Void) {
     
        guard !imageFileURLs.isEmpty else { return }
  
//        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("sbScreenshotsFile.mov")
        
        guard let outputURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("sbScreenshotsFile.mov") else { return }
        
        let settings = [AVVideoCodecKey: AVVideoCodecType.h264,
                        AVVideoWidthKey: 500,
                       AVVideoHeightKey: 400,] as [String : Any]
        
        if let videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mov) {
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            
            input.mediaTimeScale = CMTimeScale(bitPattern: 600)
            input.expectsMediaDataInRealTime = true
            
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
            
            if videoWriter.canAdd(input) {
                videoWriter.add(input)
            }
            
            var actualFrameCount = Double()
            for i in actualFPSArray {
                actualFrameCount += i
            }
            print("actualFrameCount total: \(actualFrameCount)")
        
            
            videoWriter.startWriting()
//            let presentationStartTime =  CMTimeMake(value: Int64(1), timescale: Int32(30))
            let presentationStartTime =  CMTimeMake(value: Int64(0), timescale: Int32(30))
            videoWriter.startSession(atSourceTime: presentationStartTime)

            print("INDEX COUNT FOR imageFileURLs: \(imageFileURLs.count)")
            print("imageFileURLs INTENDED FRAME count: \(Double(30 * imageFileURLs.count))")
            
            var frameCountDifference = actualFrameCount - Double(30 * imageFileURLs.count)
            
            if frameCountDifference < 0 {
                frameCountDifference = (frameCountDifference * -1)
            }
           
            print("frameCountDifference: \(frameCountDifference)")
     
            var frameCount = 0
            var presentationTimeTrack = CMTime(value: 0, timescale: 30)
            let countDividiedRounded = Int(round(frameCountDifference))
            let startingPoint = (imageFileURLs.count - 1) - (countDividiedRounded * 30)
            print("startingPoint: \(startingPoint)")

            while frameCount <= imageFileURLs.count - 1 {

                if countDividiedRounded <= 0 || countDividiedRounded == 1 {
                    print("Loop A")
                    do {
                        try autoreleasepool {
                            let imageData = try Data(contentsOf: imageFileURLs[frameCount])
                            if let image = UIImage(data: imageData) {
                                if input.isReadyForMoreMediaData {
                                    let presentationTime = CMTimeMake(value: Int64(frameCount), timescale: Int32(30))
                                    print("Loop A presentTime: \(presentationTime)")
                                    if let pixelBuffer = image.pixelBuffer(width: Int(image.size.width), height: Int(image.size.height)) {
                                        adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                                        
                                    }
                                }
                            }
                        }
                    } catch {
                        print("Loop A Error for autoreleasepool: \(error)")
                    }
                } else {
                    print("Loop B")
                    print("Loop B frameCount: \(frameCount)")

                    do {
                        try autoreleasepool {
                 
                                print("Loop B-1 count OUTSIDE STRIDE. Count \(frameCount)")
  
                                let imageData = try Data(contentsOf: imageFileURLs[frameCount])
                                if let image = UIImage(data: imageData) {
                                    if input.isReadyForMoreMediaData {
                                        let timeToAdd = CMTime(value: CMTimeValue(1), timescale: 30)
                                        let presentationTimeToAdd = CMTimeAdd(presentationTimeTrack, timeToAdd)
                                        
                                        print("Loop B-1 presentTime: \(presentationTimeToAdd)")
                                        if let pixelBuffer = image.pixelBuffer(width: Int(image.size.width), height: Int(image.size.height)) {
                                            adaptor.append(pixelBuffer, withPresentationTime: presentationTimeToAdd)
                                            presentationTimeTrack = presentationTimeToAdd
                                        }
                                    }
                                }
                                
                            
                            
                        }
                    } catch {
                            print("Error for autoreleasepool: \(error)")
                        }
 
                }
                frameCount += 1
                
            }
            
            
            input.markAsFinished()
//            videoWriter.endSession(atSourceTime: presentationTimeTrack)
            videoWriter.finishWriting {
                print("videoWriter: finished writing")
                self.imageFileURLs.removeAll()
                self.documentsDirectory.removeAllCachedResourceValues()
                completion(outputURL)
            }
        }
        
    }
    
    func overlayVideos(videoURL1: URL, videoURL2: URL) async throws -> Void {
        print("Overlaying Videos")
        let composition = AVMutableComposition()
        
        // Scoreboard - videoURL1 (videoAsset1)
        let videoAsset1 = AVAsset(url: videoURL1)
        // Camera - videoURL2 (videoAsset2)
        let videoAsset2 = AVAsset(url: videoURL2)
        
        let videoAsset1Tracks = try? await videoAsset1.loadTracks(withMediaType: .video)
        let videoAsset2Tracks = try? await videoAsset2.loadTracks(withMediaType: .video)

        
        if let track1 = videoAsset1Tracks?.first, let track2 = videoAsset2Tracks?.first {
            
            let compositionTrack1 = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            let compositionTrack2 = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            let compositionTrack3 = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            
//            let timetostart = CMTime(value: 10, timescale: Int32(30))
            try? await compositionTrack1?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset1.load(.duration)),
                                                          of: track1,
                                                          at: .zero)
            try? await compositionTrack2?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset2.load(.duration)),
                                                          of: track2,
                                                          at: .zero)
            
            let track1FrameRate = compositionTrack1?.nominalFrameRate
            let track2FrameRate = compositionTrack2?.nominalFrameRate
            
            print("track1FrameRate: \(String(describing: track1FrameRate))")
            print("track2FrameRate: \(String(describing: track2FrameRate))")
            
            // Load AUDIO from: "Camera - videoURL2 (videoAsset2)"
            try? await compositionTrack3?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset2.load(.duration)),
                                                          of: videoAsset2.loadTracks(withMediaType: .audio)[0],
                                                          at: .zero)
            
            let videoComposition = AVMutableVideoComposition()
            // Assuming 30 frames per second

            videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
    
            try? await videoComposition.renderSize = CGSize(
                width: max(track1.load(.naturalSize).width, track2.load(.naturalSize).width),
                height: max(track1.load(.naturalSize).height, track2.load(.naturalSize).height)
            )
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(start: .zero, duration: composition.duration)
            
            let layerInstruction1 = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack1!)
            let layerInstruction2 = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack2!)
            
            // layerInstruction1 for: Scoreboard - videoURL1
//            let topRightTransformRotatedLeft: CGAffineTransform = .identity.translatedBy(x: -50, y: 520).scaledBy(x: 2.8, y: 1).rotated(by: -.pi/2)
//            layerInstruction1.setTransform(topRightTransformRotatedLeft, at: .zero)
//            layerInstruction1.setCropRectangle(CGRect(x: 385, y: 30, width: 100, height: 117), at: .zero)
            
//            let topRightTransformRotatedLeft: CGAffineTransform = .identity.translatedBy(x: 10, y: 220).scaledBy(x: 1.1, y: 0.4).rotated(by: -.pi/2)
//            layerInstruction1.setTransform(topRightTransformRotatedLeft, at: .zero)
//            layerInstruction1.setCropRectangle(CGRect(x: 295, y: 30, width: 1800, height: 240), at: .zero)
            
            let topRightTransformRotatedLeft: CGAffineTransform = .identity.translatedBy(x: 10, y: 320).scaledBy(x: 1.6, y: 0.6).rotated(by: -.pi/2)
            layerInstruction1.setTransform(topRightTransformRotatedLeft, at: .zero)
            layerInstruction1.setCropRectangle(CGRect(x: 295, y: 30, width: 2400, height: 240), at: .zero)
            
            instruction.layerInstructions = [layerInstruction1, layerInstruction2]
            videoComposition.instructions = [instruction]
            
            guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
                fatalError("Error unwrapping AVAssetExportSession")
            }
            
            _exporter = exporter
            _exporter?.outputFileType = .mov
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("overlayedFinalVideoFile.mov")
            _exporter?.outputURL = outputURL
            _exporter?.videoComposition = videoComposition
            
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateExportProgress), userInfo: nil, repeats: true)
            }
            self.timer.fire()
            await exporter.export()
            
            print("DDD AWAIT")
            
            DispatchQueue.main.async {
                print("DDD DONE")
                self.finalVideoURL
                = outputURL
                self.imageFileURLs.removeAll()
                self.actualFPSArray.removeAll()
            }
        }
    }
    
    func deleteFilesInFileManager(cm: CameraViewModel) {
        DispatchQueue.global(qos: .utility).async {
//            let fileName1URLToDelete = FileManager.default.temporaryDirectory.appendingPathComponent(fileName1ToDelete)
            guard let fileName1URLToDelete = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("sbScreenshotsFile.mov") else { return }
            let path = fileName1URLToDelete.path
            let fileExists = FileManager.default.fileExists(atPath: path)
            
            if fileExists {
                do {
                    try FileManager.default.removeItem(at: fileName1URLToDelete)
                    print("File: sbScreenshotsFile.mov - deleted successfully.")
                    
                    let fileName2ToDelete = "overlayedFinalVideoFile.mov"
                    let file2URLToDelete = FileManager.default.temporaryDirectory.appendingPathComponent(fileName2ToDelete)
                    try FileManager.default.removeItem(at: file2URLToDelete)
                    print("File: overlayedFinalVideoFile.mov - deleted successfully.")
                    
                    print("DEBUGG1: \(cm.videoURL?.lastPathComponent)")
                    if let file3NameToDelete = cm.videoURL {
                        print("DEBUGG2: \(cm.videoURL)")
                        try FileManager.default.removeItem(at: file3NameToDelete)
                        print("File: \(file3NameToDelete) - deleted successfully")
                    }
                    
                } catch {
                    print("Error deleting from FileManager: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc func updateExportProgress() {
        if _exporter?.progress != 1.0 {
            if let progress = _exporter?.progress {
                print("Progress: \(progress)")
                let progressData:[String: Float] = ["progressData": progress]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateCircularProgressView"), object: nil, userInfo: progressData)
            }
        } else {
            timer.invalidate()
            let progressData:[String: Float] = ["progressData": 1.0]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateCircularProgressView"), object: nil, userInfo: progressData)
        }
    }
    
    func hardResetViewRecorder(_ cm: CameraViewModel) {
      
        
        self.displayLink?.remove(from: RunLoop.main, forMode: .default)
        
  
        displayLink?.invalidate()
        displayLink = nil
        self.imageFileURLs.removeAll()
        self.actualFPSArray.removeAll()
        self.documentsDirectory.removeAllCachedResourceValues()
        videoCurrentlySaving = false
        
        deleteFilesInFileManager(cm: cm)
        timer.invalidate()
        self.finalVideoURL = nil
        
    }
    
}

extension UIImage {
    
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, options as CFDictionary, &pixelBuffer)

        guard let buffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        guard let cgImage = cgImage, let cgContext = context else {
            return nil
        }

        cgContext.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }
  
}


