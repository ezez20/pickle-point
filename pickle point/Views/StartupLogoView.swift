//
//  StartupLogoView.swift
//  pickle point
//
//  Created by Ezra Yeoh on 2/1/24.
//

import SwiftUI

struct StartupLogoView: View {
    
    var body: some View {
        ZStack {
            Color("customBlue")
            Image("appstore_AppIcons2")
                .resizable()
                .frame(width: 100, height: 100)
        }
      
    }
}

struct StartupLogoView_Previews: PreviewProvider {
    static var previews: some View {
        StartupLogoView()
    }
}
