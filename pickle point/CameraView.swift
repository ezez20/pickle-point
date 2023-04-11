//
//  CameraView.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/11/23.
//

import Foundation
import SwiftUI
import AVFoundation
import CoreData

struct CameraView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        
        ZStack {
            
            HStack {
                
                VStack(alignment: .leading) {
                    
                    // Add point: Button
                    HStack(spacing: 30) {
                        
                        // Undo point: Button
                        Text("0")
                            .font(.largeTitle)
                          
                        Image(systemName: "soccerball")
                            .fixedSize()
                        
                    }
                    .padding(40)
              
        
                    // switch: Button
                    Button {
                        // User hits record - video
                        
                    } label: {
                        ZStack {
                            Image(systemName: "circle")
                                .resizable()
                                .frame(width: 70, height: 70)
                            Text("2")
                                .font(.largeTitle)
                               
                        }
                    }
                    .padding(40)
                    
                    HStack(spacing: 30) {
                        
                        // Undo point: Button
                        Text("0")
                            .font(.largeTitle)
                        
                        Image(systemName: "soccerball")
                            .fixedSize()
                            
                        
                    }
                    .padding(40)
                 
                    
                    
                }
                .foregroundColor(.white)
                
                
                Spacer()
                
                
                
                // BUTTONS: right side
                VStack {
                    
                    // Add point: Button
                    Button() {
                        // Reset point
                        
                    } label: {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 70, height: 70)
                    }
                    .padding(40)
              
        
                    // Record/Stop video: Button
                    Button {
                        // User hits record - video
                        
                    } label: {
                        Image(systemName: "circle")
                            .resizable()
                            .frame(width: 90, height: 90)
                    }
              
                    // Undo point: Button
                    Button {
                        // Add point
                        
                    } label: {
                        Image(systemName: "arrow.uturn.backward.circle")
                            .resizable()
                            .frame(width: 70, height: 70)
                    }
                    .padding(40)
                    
                    
                }
                .foregroundColor(.white)
                
                
            }
            
        }
        .background(.gray)
        
    }
    
}

struct CameraView_Previews: PreviewProvider {
    
    static var previews: some View {
        CameraView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
    
}
