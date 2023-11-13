//
//  ScoreBoardView.swift
//  pickle point
//
//  Created by Ezra Yeoh on 11/10/23.
//

import SwiftUI

struct ScoreBoardView: View {
    
    @State private var team1Score = 0
    @State private var team2Score = 0
    @State private var currentServer = 2
    @State private var currentlyTeam1Serving = true
    @State private var currentlyTeam2Serving = false
    @State private var sideout = false
    
    @State private var undoTeam1Score = 0
    @State private var undoTeam2Score = 0
    @State private var undoCurrentServer = 2
    @State private var undoCurrentlyTeam1Serving = true
    @State private var undoCurrentlyTeam2Serving = false
    @State private var undoSideout = false
    
    @State var timePassed = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var serverLabel = "Server ONE"
    @State private var showServerLabel = false
    
    var body: some View {
//        Text("\(gameTime(timePassed: timePassed))")
        GeometryReader { geo in
            Text("")
                .rotationEffect(.degrees(90))
                .font(.largeTitle)
                .foregroundColor(.white)
                .shadow(color: .yellow, radius: 10)
                .position(x: geo.size.width - 20, y: geo.size.height/2)
            //            .onReceive(timer) { _ in
            //                timePassed += 1
            //            }
            
            Text(sideout ? "Side Out" : "")
                .font(.title)
                .foregroundColor(.white)
                .shadow(color: .green, radius: 10)
                .rotationEffect(.degrees(90))
                .position(x: geo.size.width - 50, y: geo.size.height/2)
            
            Text(showServerLabel ? serverLabel : "")
                .font(.title)
                .foregroundColor(.white)
                .shadow(color: currentlyTeam1Serving ? .green : .red, radius: 10)
                .rotationEffect(.degrees(90))
                .position(x: geo.size.width - 50, y: geo.size.height/2)
            
            VStack(alignment: .center, spacing: 5) {
                
                Text("\(currentlyTeam1Serving ? team1Score : team2Score)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .shadow(color: currentlyTeam1Serving ? .green : .red, radius: 10)
                    .rotationEffect(.degrees(90))
                
                Text("\(currentlyTeam2Serving ? team1Score : team2Score)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .shadow(color: currentlyTeam2Serving ? .green : .red, radius: 10)
                    .rotationEffect(.degrees(90))
                
                VStack {
                    Image(systemName: "soccerball")
                        .fixedSize()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.green)
                        .rotationEffect(.degrees(90))
                    
                    Text("\(sideout ? "S" : "\(currentServer)")")
                        .font(.headline)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(90))
                }
                .padding(10)
                
            }
            .frame(width: 50, height: 180)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .position(x: geo.size.width - 30, y: 100)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 1.0).onEnded({ _ in
//                    resetGame()
                })
            )
        }
    }
    
}

struct ScoreBoardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreBoardView()
    }
}
