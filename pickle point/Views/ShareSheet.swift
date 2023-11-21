//
//  ShareSheet.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/13/23.
//

import SwiftUI

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


// UIKIT: Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    
    var items: [Any]
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
