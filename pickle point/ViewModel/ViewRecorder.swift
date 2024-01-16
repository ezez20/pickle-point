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

final class ViewRecorder: NSObject, ObservableObject {
    
    var images = [UIImage]()
    var imageFileURLs = [URL]()
//    var imageFileUrlIDs = [String]()
    var displayLink: CADisplayLink?
    var sourceView: UIView?
    var caDisplayLinkVideoURL: URL?
    var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var fileURLDirectory: URL?
    
    
    @Published var finalVideoURL: URL?
    @Published var videoCurrentlySaving = false
    

    func startRecording(controller: ScoreBoardVC, completion: @escaping () -> Void) {
        self.sourceView = controller.view
//        self.sourceView = controller.scoreBoardViewFrame
        self.fileURLDirectory = documentsDirectory.appendingPathComponent("screenshotmages")
        if let url = fileURLDirectory {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory: \(error)")
            }
        }
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
//        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 60, __preferred: 60)
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 30, __preferred: 30)
        
        // The following fixed the frame sync issue of the scoreboard.
//        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: Float(UIScreen.main.maximumFramesPerSecond), __preferred: Float(UIScreen.main.maximumFramesPerSecond))
        print("Max frame: \(Float(UIScreen.main.maximumFramesPerSecond))")
//        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, __preferred: 120)
//        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60, __preferred: 60)
        DispatchQueue.main.async {
            self.displayLink?.add(to: RunLoop.main, forMode: .default)
        }

//        displayLink?.add(to: RunLoop.main, forMode: .default)
//        displayLink?.add(to: .current, forMode: .common)
        
        completion()
    }
    
    func stop(_ cameraVideoURL: URL?) {
        print("videoRecorder: Stopped Recording")
        DispatchQueue.main.async {
            self.displayLink?.remove(from: .main, forMode: .default)
//            self.displayLink?.remove(from: .current, forMode: .common)
        }
//        self.displayLink?.remove(from: .main, forMode: .default)
        
        displayLink?.invalidate()
        displayLink = nil
        
        guard let cameraVideoURL = cameraVideoURL else {
            print("cameraVideoURL nil")
            return
        }
        
        writeToVideo() { url in
            Task {
                do {
//                    guard let caDisplayLinkVideoURLUnwrapped = self.caDisplayLinkVideoURL else { return }
//                    try await self.overlayVideos(videoURL1: caDisplayLinkVideoURLUnwrapped, videoURL2: cameraVideoURL)
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
//        imageFileURLs.removeAll()
//        imageFileUrlIDs.removeAll()
//        let actualFramesPerSecond = 1 / (displayLink.targetTimestamp - displayLink.timestamp)
//        print("Frame: \(actualFramesPerSecond)")
        if let sourceView = sourceView {
            let render = UIGraphicsImageRenderer(size: sourceView.frame.size)
//            let render = UIGraphicsImageRenderer(size: CGSize(width: 80, height: 180))
         
         
            let image = render.image { (ctx) in
                // Adjust sharpness of rendered image
                sourceView.layer.contentsScale = 1.0
                sourceView.layer.shouldRasterize = true
                sourceView.layer.rasterizationScale = 0.5
                
                sourceView.layer.render(in: ctx.cgContext)
            }
            if let imageData = image.pngData() {
                let imageUrlID = "imageID\(UUID().uuidString)"
                if let url = fileURLDirectory {
                    let imageURLPATH = url.appendingPathComponent(imageUrlID).appendingPathExtension("png")
                    do {
                        try imageData.write(to: imageURLPATH)
//                        imageFileUrlIDs.append(imageUrlID)
                        imageFileURLs.append(imageURLPATH)
                        print("Writing image")
                        print("Writing image ImageFileURL: \(imageURLPATH)")
                    } catch {
                        print("Error imageData.write(to: fileURL)")
                    }
                    //                images.append(image)
                }
            }
        }
    }

    private func writeToVideo(completion: @escaping (URL?) -> Void) {
        //        guard !images.isEmpty else {
        //            return
        //        }
        
        guard !imageFileURLs.isEmpty else { return }
        
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.mp4")
        
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
            print("DDD deez")
            videoWriter.startSession(atSourceTime: CMTime.zero)
            let fps: Int32 = 30
            //                    let fps: Int32 = 60
            //            let fps: Int32 = 120
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
                            //                            if let pixelBuffer = image.pixelBuffer(width: Int(image.size.width), height: Int(image.size.height)) {
                            //                                adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                            //                            }
                            
                            //                        if let pixelBuffer = image.pixelBuffer(width: Int(image.size.width), height: Int(image.size.height)) {
                            //                            adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                            //                        }
                        }
                    }
                } catch {
                    print("Error for autoreleasepool: \(error)")
                }
                
            }
            
            print("DDD deez 2")
            input.markAsFinished()
            print("DDD deez 3")
            videoWriter.finishWriting {
                print("DDD deez 4")
                //                    DispatchQueue.main.async {
                //                        self.caDisplayLinkVideoURL = outputURL
                //                        completion()
                //                    }
                
                //                        self.caDisplayLinkVideoURL = outputURL
                
                self.imageFileURLs.removeAll()
                //                        self.imageFileUrlIDs.removeAll()
                self.documentsDirectory.removeAllCachedResourceValues()
                completion(outputURL)
            }
        }
        
    }
    
    func overlayVideos(videoURL1: URL, videoURL2: URL) async throws -> Void {
        print("Overlaying Videos")
        let composition = AVMutableComposition()
        
        let videoAsset1 = AVAsset(url: videoURL1)
        let videoAsset2 = AVAsset(url: videoURL2)
        
        let videoAsset1Tracks = try? await videoAsset1.loadTracks(withMediaType: .video)
        let videoAsset2Tracks = try? await videoAsset2.loadTracks(withMediaType: .video)
        
        guard let track1 = videoAsset1Tracks?.first else {
            fatalError("Error getting track1 from videoAsset1Tracks")
        }
        guard let track2 = videoAsset2Tracks?.first else {
            fatalError("Error getting track2 from videoAsset1Tracks")
        }
        
        let compositionTrack1 = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let compositionTrack2 = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        
        try? await compositionTrack1?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset1.load(.duration)),
                                                      of: track1,
                                                      at: .zero)
        try? await compositionTrack2?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset2.load(.duration)),
                                                      of: track2,
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
        
//        let naturalSize = compositionTrack1?.naturalSize
//        let halfWidth = (naturalSize?.width ?? 0) / 2
////        let halfHeight = (naturalSize?.height ?? 0) / 2
////        let topLeftTransform: CGAffineTransform = .identity.translatedBy(x: 0, y: 0).scaledBy(x: 0.5, y: 0.5)
//        let topRightTransform: CGAffineTransform = .identity.translatedBy(x: halfWidth + 100, y: 200).scaledBy(x: 2, y: 2).rotated(by: -.pi/2)
//        print("DDD HALF: \(halfWidth)")
        let topRightTransform: CGAffineTransform = .identity.translatedBy(x: -50, y: 520).scaledBy(x: 2.8, y: 1).rotated(by: -.pi/2)
//        print("DDD halfWidth: \(halfWidth), transform: \(topRightTransform)")
////        let bottomLeftTransform: CGAffineTransform = .identity.translatedBy(x: 0, y: halfHeight).scaledBy(x: 0.5, y: 0.5)
////        let bottomRightTransform: CGAffineTransform = .identity.translatedBy(x: halfWidth, y: halfHeight).scaledBy(x: 0.5, y: 0.5)
//        layerInstruction1.setTransform(topRightTransform, at: .zero)
        
        // Adjust the transform if needed (Adjust rotation)
//        let desiredRotation = CGAffineTransform(rotationAngle: -.pi/2)
//        layerInstruction2.setTransform(desiredRotation, at: .zero)
//        layerInstruction2.setTransform(transform, at: .zero)
//
//        try? await layerInstruction1.setTransform(track1.load(.preferredTransform).concatenating(topRightTransform), at: .zero)
        layerInstruction1.setTransform(topRightTransform, at: .zero)
        layerInstruction1.setCropRectangle(CGRect(x: 385, y: 30, width: 100, height: 117), at: .zero)
//        layerInstruction1.setCropRectangle(CGRect(x: 300, y: -120, width: 80, height: 350), at: .zero)
//        try? await layerInstruction2.setTransform(track2.load(.preferredTransform), at: .zero)

//        let videoLayer = CALayer()
//        videoLayer.frame = CGRect(x: 0, y: 0, width: 1280.0, height: 720.0)
//        videoLayer.isHidden = false
//        videoLayer.cornerRadius = 15
//        videoLayer.backgroundColor = UIColor(.green).cgColor
//        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(additionalLayer: videoLayer, asTrackID: 3)

        instruction.layerInstructions = [layerInstruction1, layerInstruction2]
        videoComposition.instructions = [instruction]
        
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            fatalError("Error unwrapping AVAssetExportSession")
        }
        
        exporter.outputFileType = .mp4
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("outputURL.mp4")
        exporter.outputURL = outputURL
        exporter.videoComposition = videoComposition
        
        await exporter.export()
        print("DDD AWAIT")
        
        DispatchQueue.main.async {
            print("DDD DONE")
            self.finalVideoURL = outputURL
        }
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

//extension View {
//    func snapshot(_ size: CGSize) -> UIView? {
//        let controller = UIHostingController(rootView: self)
//        controller.view.backgroundColor = .clear
//        guard let view = controller.view else {
//            fatalError("UIView: Error for snapshot")
//        }
//        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
//        let image = renderer.image { _ in
//            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
//            print("View rect: \(view.bounds)")
//        }
//
//        return UIImageView(image: image)
//    }
//}


