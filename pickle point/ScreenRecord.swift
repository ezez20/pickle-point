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

