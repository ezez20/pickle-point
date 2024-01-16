//
//  ViewController.swift
//  pickle point
//
//  Created by Ezra Yeoh on 11/27/23.
//

import UIKit
import AVFoundation

class ScoreBoardVC: UIViewController {
    
    var viewRecoder: ViewRecorder
    let titleLogo = UIImageView()
    
    var sbm: ScoreBoardManager
    
    let scoreBoardViewFrame: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        return view
    }()
    
    var team1ScoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGreen
        label.text = "0"
        label.font = .systemFont(ofSize: 35)
        label.transform = CGAffineTransform(rotationAngle: .pi/2)
        label.frame.size = CGSize(width: 30, height: 30)
        return label
    }()
    
    let dashLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.text = "-"
        label.font = .systemFont(ofSize: 35)
        label.transform = CGAffineTransform(rotationAngle: .pi/2)
        label.frame.size = CGSize(width: 10, height: 10)
        return label
    }()
    
    var team2ScoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.text = "0"
        label.font = .systemFont(ofSize: 35)
        label.transform = CGAffineTransform(rotationAngle: .pi/2)
        label.frame.size = CGSize(width: 30, height: 30)
        return label
    }()
    
    let pickleBallImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "soccerball")
        imageView.frame.size = CGSize(width: 10, height: 10)
        imageView.transform = CGAffineTransform(rotationAngle: .pi/2)
        imageView.tintColor = .systemYellow
        return imageView
    }()
    
    let currentlyScoringLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemMint
        label.text = "2"
        label.font = .systemFont(ofSize: 35)
        label.transform = CGAffineTransform(rotationAngle: .pi/2)
        label.frame.size = CGSize(width: 30, height: 30)
        return label
    }()
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.text = "0:00"
        label.font = .systemFont(ofSize: 25)
        label.transform = CGAffineTransform(rotationAngle: .pi/2)
        label.frame.size = CGSize(width: 140, height: 40)
        return label
    }()
    
    let ppLogo: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "AppIcon")
        imageView.contentMode = .scaleAspectFit
        imageView.transform = imageView.transform.rotated(by: .pi/2)
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("ViewController DID LOAD")
//        view.backgroundColor = .systemBlue
        
        NotificationCenter.default.addObserver(self, selector: #selector(startVideoRecorder), name: NSNotification.Name("startViewRecorder"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimer), name: NSNotification.Name("updateTimer"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetTimer), name: NSNotification.Name("resetTimer"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateVC), name: NSNotification.Name("updateVC"), object: nil)
        
        // SCOREBOARD FRAME
        view.addSubview(scoreBoardViewFrame)
        scoreBoardViewFrame.translatesAutoresizingMaskIntoConstraints = false
        scoreBoardViewFrame.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        scoreBoardViewFrame.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        scoreBoardViewFrame.heightAnchor.constraint(equalToConstant: 180).isActive = true
        scoreBoardViewFrame.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        //team1ScoreLabel
        scoreBoardViewFrame.addSubview(team1ScoreLabel)
        team1ScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        team1ScoreLabel.topAnchor.constraint(equalTo: scoreBoardViewFrame.topAnchor, constant: 10).isActive = true
        team1ScoreLabel.centerXAnchor.constraint(equalTo: scoreBoardViewFrame.centerXAnchor, constant: 10).isActive = true

        //dashLabel
        scoreBoardViewFrame.addSubview(dashLabel)
        dashLabel.translatesAutoresizingMaskIntoConstraints = false
        dashLabel.topAnchor.constraint(equalTo: team1ScoreLabel.bottomAnchor, constant: -10).isActive = true
        dashLabel.centerXAnchor.constraint(equalTo: scoreBoardViewFrame.centerXAnchor, constant: 10).isActive = true
        
        //team2ScoreLabel
        scoreBoardViewFrame.addSubview(team2ScoreLabel)
        team2ScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        team2ScoreLabel.topAnchor.constraint(equalTo: dashLabel.bottomAnchor, constant: -10).isActive = true
        team2ScoreLabel.centerXAnchor.constraint(equalTo: scoreBoardViewFrame.centerXAnchor, constant: 10).isActive = true
        
        // pickleBallImageView
        scoreBoardViewFrame.addSubview(pickleBallImageView)
        pickleBallImageView.translatesAutoresizingMaskIntoConstraints = false
        pickleBallImageView.topAnchor.constraint(equalTo: team2ScoreLabel.bottomAnchor, constant: 0).isActive = true
        pickleBallImageView.centerXAnchor.constraint(equalTo: scoreBoardViewFrame.centerXAnchor, constant: 10).isActive = true
        
        // currentlyScoringLabel
        scoreBoardViewFrame.addSubview(currentlyScoringLabel)
        currentlyScoringLabel.translatesAutoresizingMaskIntoConstraints = false
        currentlyScoringLabel.topAnchor.constraint(equalTo: pickleBallImageView.bottomAnchor, constant: -5).isActive = true
        currentlyScoringLabel.centerXAnchor.constraint(equalTo: scoreBoardViewFrame.centerXAnchor, constant: 10).isActive = true
        
        // timerLabel
        scoreBoardViewFrame.addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.centerXAnchor.constraint(equalTo: scoreBoardViewFrame.leftAnchor, constant: 18).isActive = true
        timerLabel.centerYAnchor.constraint(equalTo: scoreBoardViewFrame.centerYAnchor).isActive = true
        timerLabel.text = String(sbm.gameTime(timePassed: sbm.timePassed))
        
        // ppLogo
        ppLogo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ppLogo)
        ppLogo.topAnchor.constraint(equalTo: scoreBoardViewFrame.bottomAnchor, constant: 10).isActive = true
        ppLogo.topAnchor.constraint(equalTo: scoreBoardViewFrame.bottomAnchor, constant: 0).isActive = true
        ppLogo.centerXAnchor.constraint(equalTo: scoreBoardViewFrame.centerXAnchor).isActive = true
        ppLogo.topAnchor.constraint(equalTo: scoreBoardViewFrame.bottomAnchor).isActive = true
        ppLogo.heightAnchor.constraint(equalTo: scoreBoardViewFrame.widthAnchor).isActive = true
        
    }
    
    init(viewRecoder: ViewRecorder, sbm: ScoreBoardManager , session: AVCaptureSession?) {
        self.viewRecoder = viewRecoder
        self.sbm = sbm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ScoreBoardVC {
    
    @objc func startVideoRecorder() {
        print("Start Video Recorder")
        viewRecoder.startRecording(controller: self) {
        }
    }
    @objc func updateTimer() {
        print("Deez update timer")
        timerLabel.text = String(sbm.gameTime(timePassed: sbm.timePassed))
    }
    @objc func resetTimer() {
        timerLabel.text = "0:00"
        team1ScoreLabel.text = String(sbm.team1Score)
        team2ScoreLabel.text = String(sbm.team2Score)
        currentlyScoringLabel.text = String(sbm.currentServer)
        print("Scoreboard VC: resetTimer")
    }
    @objc func updateVC() {
        if sbm.currentlyTeam1Serving {
            team1ScoreLabel.textColor = .systemGreen
            team2ScoreLabel.textColor = .systemGray
            team1ScoreLabel.text = String(sbm.team1Score)
            team2ScoreLabel.text = String(sbm.team2Score)
        } else {
            team1ScoreLabel.textColor = .systemRed
            team2ScoreLabel.textColor = .systemGray
            team1ScoreLabel.text = String(sbm.team2Score)
            team2ScoreLabel.text = String(sbm.team1Score)
        }
        
        if sbm.sideout {
            currentlyScoringLabel.text = "S"
        } else {
            currentlyScoringLabel.text = String(sbm.currentServer)
        }
        
        if sbm.timePassed == 0 {
            timerLabel.text = "0:00"
        }
    }
    
}
