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
    
    @State private var gameStart = false
    
    @State private var team1Score = 0
    @State private var team2Score = 0
    @State private var currentServer = 2
    @State private var currentlyTeam1Serving = true
    @State private var currentlyTeam2Serving = false
    
//    @StateObject private var camera = CameraModel()
//    var session = AVCaptureSession()
    
    var body: some View {
        
        ZStack {
            
            HStack(alignment: .top) {
                
                VStack(alignment: .leading) {
                    
                    // Add point: Button
                    HStack(spacing: 30) {
                        
                        // Undo point: Button
                        Text("\(team1Score)")
                            .font(.largeTitle)
                          
                        Image(systemName: currentlyTeam1Serving ? "soccerball" : "")
                            .fixedSize()
                        
                    }
                    .padding(40)
              
        
                    // next point: Button
                    Button {
                        // next point func
                        nextPoint()
                        
                        
                    } label: {
                        ZStack {
                            Image(systemName: "circle")
                                .resizable()
                                .frame(width: 70, height: 70)
                            Text("\(currentServer)")
                                .font(.largeTitle)
                               
                        }
                    }
                    .padding(40)
                    
                    HStack(spacing: 30) {
                        
                        // Undo point: Button
                        Text("\(team1Score)")
                            .font(.largeTitle)
                        
                        Image(systemName: currentlyTeam2Serving ? "soccerball" : "")
                            .fixedSize()
                            
                        
                    }
                    .padding(40)
                 
                    
                    
                }
                .foregroundColor(.gray)
                
                Spacer()
                
                HStack {
                    Text("0")
                        .font(.title)
                        .foregroundColor(.gray)
                    Text(":")
                        .font(.title)
                        .foregroundColor(.gray)
                    Text("0")
                        .font(.title)
                        .foregroundColor(.gray)
                    Text("0")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .padding(30)
                
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
                        startGame()
                        
                    } label: {
                        Image(systemName: "circle")
                            .resizable()
                            .frame(width: 90, height: 90)
                            .foregroundColor(gameStart ? .red : .green)
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
                .foregroundColor(.gray)
                
                
            }
            
        }
       
        
    }
    
    func startGame() {
        
        gameStart.toggle()
        
    }
    
    func nextPoint() {
        
    }
    
}

struct CameraView_Previews: PreviewProvider {
    
    static var previews: some View {
        CameraView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
    
}
