//
//  CustomProgressView.swift
//  pickle point
//
//  Created by Ezra Yeoh on 1/27/24.
//

import SwiftUI

struct CustomProgressView: View {
    
    @ObservedObject var circularViewProgress: CircularProgressView
    
    var body: some View {
        Image(uiImage: UIImage(named: circularViewProgress.customPickleBallViewCount) ?? UIImage())
            .resizable()
            .frame(width: 50, height: 50)
    }
}

struct CustomProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CustomProgressView(circularViewProgress: CircularProgressView())
    }
}
