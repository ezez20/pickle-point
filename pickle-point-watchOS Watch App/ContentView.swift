//
//  ContentView.swift
//  pickle-point-watchOS Watch App
//
//  Created by Ezra Yeoh on 4/21/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModelWatch = WatchKitManager_WatchOS()
    @StateObject var watchDelegate = WatchDelegate()
    
    var body: some View {
        ControlViewWatchOS(viewModelWatch: viewModelWatch, watchDelegate: watchDelegate)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
