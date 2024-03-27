//
//  StartupLogoView.swift
//  pickle point
//
//  Created by Ezra Yeoh on 2/1/24.
//

import SwiftUI

struct StartupLogoView: View {
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color("customBlue")
                    .ignoresSafeArea()
        
                Image("PicklePoint_StartupScreen")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

struct StartupLogoView_Previews: PreviewProvider {
    static var previews: some View {
        StartupLogoView()
    }
}
