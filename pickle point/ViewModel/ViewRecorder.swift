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
    var displayLink: CADisplayLink?
//    var completion: ((URL?) -> Void)?
    var sourceView: UIView?
    
    @Published var videoURL: URL?
    @Published var videoCurrentlySaving = false
    

//    func startRecording(_ view: UIView, completion: @escaping (URL?) -> Void) {
//        self.completion = completion
//        self.sourceView = view
//        displayLink = CADisplayLink(target: self, selector: #selector(tick))
//        displayLink?.add(to: RunLoop.main, forMode: .common)
//    }
    
    func startRecording(_ view: RecordingView, completion: @escaping () -> Void) {
//        self.completion = completion
        let uiVIew = view.snapshot()
        self.sourceView = uiVIew
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: RunLoop.main, forMode: .common)
        completion()
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        writeToVideo()
        print("videoRecorder: Stopped Recording")
    }

    @objc private func tick(_ displayLink: CADisplayLink) {
        let render = UIGraphicsImageRenderer(size: sourceView?.bounds.size ?? .zero)
        let image = render.image { (ctx) in
            sourceView?.layer.presentation()?.render(in: ctx.cgContext)
        }
        images.append(image)
    }

    private func writeToVideo() {
        guard !images.isEmpty else {
//            completion?(nil)
            return
        }
//        _filename = "PickePoint - \(Date.now.formatted(date: .abbreviated, time: .standard))"
//        let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename).mov")
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.mov")
        let settings = [AVVideoCodecKey: AVVideoCodecType.h264,
                        AVVideoWidthKey: images[0].size.width,
                        AVVideoHeightKey: images[0].size.height] as [String : Any]
        
        print("DDD images count: \(images.count)")
        print("DDD Width: \(images[0].size.width)")

        if let videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mov) {
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
            
            if videoWriter.canAdd(input) {
                videoWriter.add(input)
            }

            if videoWriter.startWriting() {
                videoWriter.startSession(atSourceTime: CMTime.zero)

                let fps: Int32 = 30
                let frameDuration = CMTime(value: 1, timescale: fps)

                for (index, image) in images.enumerated() {
                    if input.isReadyForMoreMediaData {
                        let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(index))
                        if let pixelBuffer = image.pixelBuffer(width: Int(image.size.width), height: Int(image.size.height)) {
                            adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                        }
                    }
                }

                input.markAsFinished()
                videoWriter.finishWriting {
                    DispatchQueue.main.async {
//                        self.completion?(outputURL)
                        self.videoURL = outputURL
                    }
                }
            }
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

extension View {
    func snapshot() -> UIView? {
          let controller = UIHostingController(rootView: self)
        guard let view = controller.view else {
            fatalError("UIView: Error for snapshot")
        }

          let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
          let image = renderer.image { _ in
              view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
          }
        
        print("DDD imageview: \(image.size.width)")

          return UIImageView(image: image)
      }
}

//class CameraModel: NSObject, ObservableObject {
//    // Other properties...
//
//    var viewRecorder: ViewRecorder?
//
//    override init() {
//        super.init()
//        viewRecorder = ViewRecorder()
//    }
//
//    // Other methods...
//
//    func startRecording(viewHierarchy: RecordingView, completion: @escaping () -> Void) {
//        viewRecorder?.startRecording(viewHierarchy, completion: completion)
//    }
//
//    func endRecording() {
//        viewRecorder?.stop()
//    }
//
//    // Other methods...
//}
