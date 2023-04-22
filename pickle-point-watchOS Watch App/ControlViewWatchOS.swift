//
//  ControlViewWatchOS.swift
//  pickle-point-watchOS Watch App
//
//  Created by Ezra Yeoh on 4/21/23.
//

import SwiftUI

struct ControlViewWatchOS: View {
    var body: some View {
        
        GeometryReader { rect in
            ZStack {
                VStack {
                    
                    ZStack {
                        
                        HStack {
                            Text("0")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                            Text("-")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                            Text("2")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                            Text("-")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                            Text("0")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                        }
                        
                        Button("") {
                            serverButtonTapped()
                        }
                        .buttonStyle(BorderedButtonStyle(tint: .clear))
                     
                        
                    }
                    
                    Spacer()
                    
                    HStack {
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                        }
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }

    }
    
    func serverButtonTapped() {
        print("serverButtonTapped")
    }
}

struct ControlViewWatchOS_Previews: PreviewProvider {
    static var previews: some View {
        ControlViewWatchOS()
    }
}
