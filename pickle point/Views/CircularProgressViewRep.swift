//
//  CircularProgressViewRep.swift
//  pickle point
//
//  Created by Ezra Yeoh on 12/7/23.
//

import Foundation
import SwiftUI

struct CircularProgressViewRep: UIViewRepresentable {
    
    let view = CircularProgressView()
    var viewRecorder: ViewRecorder
    
    func makeUIView(context: Context) -> UIView {
        print("CircularProgressView")
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        //
        print("updateUIView")
    }
    
    typealias UIViewType = UIView
    

}
