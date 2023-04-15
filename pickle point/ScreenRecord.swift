//
//  ScreenRecord.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/13/23.
//

import Foundation
import SwiftUI
import ReplayKit

extension View {
    
    func startRecording(enableMicrophone: Bool = true, completion: @escaping (Error?) -> ()) {
        let recorder = RPScreenRecorder.shared()
        
        recorder.isMicrophoneEnabled = true
        
        recorder.startRecording(handler: completion)
        
    }
    
    func stopRecording() async throws -> URL {
        // File will be stored in temporary directory
        let fileName = UUID().uuidString + ".mov"
        let url = FileManager.default.temporaryDirectory.appending(component: fileName)
        
        let recorder = RPScreenRecorder.shared()
        try await recorder.stopRecording(withOutput: url)
        
        return url
    }
    
    func cancelRecording() {
        let recorder = RPScreenRecorder.shared()
        recorder.discardRecording {
            print("Video recording discarded")
        }
    }
    
    // SHARE SHEET
    func shareSheet(show: Binding<Bool>, items: [Any?]) -> some View {
        return self
            .sheet(isPresented: show) {
                //
            } content: {
                // wrapping optionals
                let items = items.compactMap { item -> Any? in
                    return item
                }
                
                if !items.isEmpty {
                    ShareSheet(items: items)
                }
            }
    }
    
}

