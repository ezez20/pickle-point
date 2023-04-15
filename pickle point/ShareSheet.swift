//
//  ShareSheet.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/13/23.
//

import SwiftUI

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
