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
    
    var images = [UIImage]()
    var imageFileURLs = [URL]()
    var displayLink: CADisplayLink?
    var sourceView: UIView?
    var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var fileURLDirectory: URL?
    var timer = Timer()
    var _exporter: AVAssetExportSession?
    
    var phpStatus = PHAuthorizationStatus.notDetermined
    
    @Published var finalVideoURL: URL?
    @Published var videoCurrentlySaving = false
    
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
        if phpStatus == .denied || phpStatus == .notDetermined {
            requestPHPLibraryAuthorization()
        }
    }
    
    func startRecording(controller: ScoreBoardVC, completion: @escaping () -> Void) {
        checkPHPLibraryAuthorization()
        guard phpStatus == .authorized else { return }
        self.sourceView = controller.view
        self.fileURLDirectory = documentsDirectory.appendingPathComponent("screenshotmages")
        if let url = fileURLDirectory {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory: \(error)")
            }
        }
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 30, __preferred: 30)
        DispatchQueue.main.async {
            self.displayLink?.add(to: RunLoop.main, forMode: .default)
        }
        completion()
    }
    
    func stop(_ cameraVideoURL: URL?) {
        print("videoRecorder: Stopped Recording")
        DispatchQueue.main.async {
            self.displayLink?.remove(from: .main, forMode: .default)
        }
        
        displayLink?.invalidate()
        displayLink = nil
        
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
                sourceView.layer.contentsScale = 2.0
                sourceView.layer.shouldRasterize = true
                sourceView.layer.minificationFilter = .nearest
                sourceView.layer.rasterizationScale = UIScreen.main.scale
                sourceView.layer.render(in: ctx.cgContext)
            }
            if let imageData = image.pngData() {
                let imageUrlID = "imageID\(UUID().uuidString)"
                if let url = fileURLDirectory {
                    let imageURLPATH = url.appendingPathComponent(imageUrlID).appendingPathExtension("png")
                    do {
                        try imageData.write(to: imageURLPATH)
                        imageFileURLs.append(imageURLPATH)
                        print("Writing image")
                        print("Writing image ImageFileURL: \(imageURLPATH)")
                    } catch {
                        print("Error imageData.write(to: fileURL)")
                    }
                }
            }
        }
    }

    private func writeToVideo(completion: @escaping (URL?) -> Void) {
     
        guard !imageFileURLs.isEmpty else { return }
  
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("sbScreenshotsFile.mp4")
        
        let settings = [AVVideoCodecKey: AVVideoCodecType.h264,
                        AVVideoWidthKey: 500,
                       AVVideoHeightKey: 400] as [String : Any]
        
        if let videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) {
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
            
            if videoWriter.canAdd(input) {
                videoWriter.add(input)
            }
            
            videoWriter.startWriting()
            videoWriter.startSession(atSourceTime: CMTime.zero)
            let fps: Int32 = 30
            let frameDuration = CMTime(value: 1, timescale: fps)
    
            for (index, url) in imageFileURLs.enumerated() {
                do {
                    try autoreleasepool {
                        let imageData = try Data(contentsOf: url)
                        if let image = UIImage(data: imageData) {
                            if input.isReadyForMoreMediaData {
                                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(index))
                                print("Index time :\(Int32(index))")
                                if let pixelBuffer = image.pixelBuffer(width: Int(image.size.width), height: Int(image.size.height)) {
                                    adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                                }
                            }
                        }
                    }
                } catch {
                    print("Error for autoreleasepool: \(error)")
                }
                
            }
            
            input.markAsFinished()
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
        
//        guard let track1 = videoAsset1Tracks?.first else {
//            fatalError("Error getting track1 from videoAsset1Tracks")
//        }
//        guard let track2 = videoAsset2Tracks?.first else {
//            fatalError("Error getting track2 from videoAsset1Tracks")
//        }
        
        if let track1 = videoAsset1Tracks?.first, let track2 = videoAsset2Tracks?.first {
            
            let compositionTrack1 = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            let compositionTrack2 = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            let compositionTrack3 = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            
            try? await compositionTrack1?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset1.load(.duration)),
                                                          of: track1,
                                                          at: .zero)
            try? await compositionTrack2?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset2.load(.duration)),
                                                          of: track2,
                                                          at: .zero)
            // Load AUDIO from: "Camera - videoURL2 (videoAsset2)"
            try? await compositionTrack3?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset2.load(.duration)),
                                                          of: videoAsset2.loadTracks(withMediaType: .audio)[0],
                                                          at: .zero)
            
            let videoComposition = AVMutableVideoComposition()
            // Assuming 30 frames per second
            videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
            //        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 60)
            //        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
            try? await videoComposition.renderSize = CGSize(
                width: max(track1.load(.naturalSize).width, track2.load(.naturalSize).width),
                height: max(track1.load(.naturalSize).height, track2.load(.naturalSize).height)
            )
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(start: .zero, duration: composition.duration)
            
            let layerInstruction1 = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack1!)
            let layerInstruction2 = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack2!)
            
            // layerInstruction1 for: Scoreboard - videoURL1
            let topRightTransformRotatedLeft: CGAffineTransform = .identity.translatedBy(x: -50, y: 520).scaledBy(x: 2.8, y: 1).rotated(by: -.pi/2)
            layerInstruction1.setTransform(topRightTransformRotatedLeft, at: .zero)
            layerInstruction1.setCropRectangle(CGRect(x: 385, y: 30, width: 100, height: 117), at: .zero)
            
            instruction.layerInstructions = [layerInstruction1, layerInstruction2]
            videoComposition.instructions = [instruction]
            
            guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
                fatalError("Error unwrapping AVAssetExportSession")
            }
            
            _exporter = exporter
            _exporter?.outputFileType = .mp4
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("overlayedFinalVideoFile.mp4")
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
            }
        }
    }
    
    func deleteFilesInFileManager(cm: CameraViewModel) {
        DispatchQueue.global(qos: .utility).async {
            do {
                let fileName1ToDelete = "sbScreenshotsFile.mp4"
                let fileName1URLToDelete = FileManager.default.temporaryDirectory.appendingPathComponent(fileName1ToDelete)
                try FileManager.default.removeItem(at: fileName1URLToDelete)
                print("File: sbScreenshotsFile.mp4 - deleted successfully.")
                
                let fileName2ToDelete = "overlayedFinalVideoFile.mp4"
                let file2URLToDelete = FileManager.default.temporaryDirectory.appendingPathComponent(fileName2ToDelete)
                try FileManager.default.removeItem(at: file2URLToDelete)
                print("File: overlayedFinalVideoFile.mp4 - deleted successfully.")
                
                if let file3NameToDelete = cm.videoURL {
                        try FileManager.default.removeItem(at: file3NameToDelete)
                        print("File: \(file3NameToDelete) - deleted successfully")
                }
                
            } catch {
                print("Error deleting from FileManager: \(error.localizedDescription)")
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
        DispatchQueue.main.async {
            self.displayLink?.remove(from: .main, forMode: .default)
        }
        
        displayLink?.invalidate()
        displayLink = nil
        self.imageFileURLs.removeAll()
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


