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
    @State private var serverLabel = "Server ONE"
    @State private var showServerLabel = false
    @State private var gameResetted = false
    
    @ObservedObject var sbm: ScoreBoardManager
    @ObservedObject var viewModelPhone: WatchKitManager_iOS
    
    var body: some View {

        GeometryReader { geo in
            Text("\(sbm.gameTime(timePassed: sbm.timePassed))")
                .rotationEffect(.degrees(90))
                .font(.largeTitle)
                .foregroundColor(.white)
                .shadow(color: .yellow, radius: 10)
                .position(x: geo.size.width - 20, y: geo.size.height/2)
//                .onReceive(sbm.timer) { _ in
//                    sbm.timePassed += 1
//                }
            
            if sbm.gameResetted != true {
                Text(sbm.sideout ? "Side Out" : "")
                    .font(.title)
                    .foregroundColor(.white)
                    .shadow(color: .green, radius: 10)
                    .rotationEffect(.degrees(90))
                    .position(x: geo.size.width - 50, y: geo.size.height/2)
                
                Text(sbm.showServerLabel ? sbm.serverLabel : "")
                    .font(.title)
                    .foregroundColor(.white)
                    .shadow(color: sbm.currentlyTeam1Serving ? .green : .red, radius: 10)
                    .rotationEffect(.degrees(90))
                    .position(x: geo.size.width - 50, y: geo.size.height/2)
            }
            
            Text(sbm.gameResetted ? "Game Reset" : "")
                .font(.title)
                .foregroundColor(.white)
                .shadow(color: .red, radius: 10)
                .rotationEffect(.degrees(90))
                .position(x: geo.size.width - 50, y: geo.size.height/2)
            
            VStack(alignment: .center, spacing: 5) {
                
                Text("\(sbm.currentlyTeam1Serving ? sbm.team1Score : sbm.team2Score)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .shadow(color: sbm.currentlyTeam1Serving ? .green : .red, radius: 10)
                    .rotationEffect(.degrees(90))
                
                Text("\(sbm.currentlyTeam2Serving ? sbm.team1Score : sbm.team2Score)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .shadow(color: sbm.currentlyTeam2Serving ? .green : .red, radius: 10)
                    .rotationEffect(.degrees(90))
                
                VStack {
                    Image(systemName: "soccerball")
                        .fixedSize()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.green)
                        .rotationEffect(.degrees(90))
                    
                    Text("\(sbm.sideout ? "S" : "\(sbm.currentServer)")")
                        .font(.headline)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(90))
                }
                .padding(10)
                
            }
            .frame(width: 50, height: 180)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .position(x: geo.size.width - 30, y: 140)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 1.0).onEnded({ _ in
                    sbm.resetScore()
                })
            )
        }
        .onReceive(viewModelPhone.$messageBackToScoreBoardView) { message in
            print("Message recieved on iphone ScoreBoardView: \(message)")
            updateMessageBackFromWatch(message: message)
        }
        .onChange(of: [sbm.currentlyTeam1Serving, sbm.currentlyTeam2Serving, sbm.sideout, sbm.gameStart]) { _ in
            // Update current scores to Watch,
            sendMessageToWatch()
        }
        .onChange(of: [sbm.team1Score, sbm.team2Score, sbm.currentServer]) { _ in
            // Update current scores to Watch,
            sendMessageToWatch()
        }
        .onReceive(NotificationCenter.default.publisher(for: .reloadScoreForWatch)) { _ in
            print("reloadScoreForWatch")
            sendMessageToWatch()
        }
        
    }
    
}

extension ScoreBoardView {
    
    func sendMessageToWatch() {
        let messageBack: [String: Any] = [
            "team1Score" : sbm.team1Score,
            "team2Score": sbm.team2Score,
            "currentServer" : sbm.currentServer,
            "currentlyTeam1Serving" : sbm.currentlyTeam1Serving,
            "currentlyTeam2Serving" : sbm.currentlyTeam2Serving,
            "sideout" : sbm.sideout,
            "gameStart" : sbm.gameStart
        ]
        viewModelPhone.session.sendMessage(["message" : messageBack], replyHandler: nil)
    }
    
    func updateMessageBackFromWatch(message: [String : Any]) {
        if viewModelPhone.session.isReachable {
            print("updateMessageBackFromWatch")
            // If "side out", this will trigger the "side out" switch.
            let currentServerBack = message["currentServer"] as? Int ?? 2
            guard currentServerBack != 3 else {
                sbm.nextServer()
                return
            }
            
            if sbm.currentServer != currentServerBack {
                sbm.nextServer()
            }
            
            sbm.team1Score = message["team1Score"] as? Int ?? 0
            sbm.team2Score = message["team2Score"] as? Int ?? 0

            sbm.currentlyTeam1Serving = message["currentlyTeam1Serving"] as? Bool ?? true
            sbm.currentlyTeam2Serving = message["currentlyTeam2Serving"] as? Bool ?? false
            sbm.gameStart = message["gameStart"] as? Bool ?? false
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateVC"), object: nil)
        }
    }
    
}

struct ScoreBoardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreBoardView(
            sbm: ScoreBoardManager(),
            viewModelPhone: WatchKitManager_iOS()
        )
    }
}
