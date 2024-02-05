//
//  ScoreBoardVCRep.swift
//  pickle point
//
//  Created by Ezra Yeoh on 11/27/23.
//

import Foundation
import SwiftUI

struct ScoreBoardVCRep: UIViewControllerRepresentable {
    
    var viewRecoder: ViewRecorder
    var cameraModel: CameraViewModel
    var scoreBoardManager: ScoreBoardManager
    
    func makeUIViewController(context: Context) -> ScoreBoardVC {
        let vc = ScoreBoardVC(viewRecoder: viewRecoder, sbm: scoreBoardManager, session: cameraModel.session)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ScoreBoardVC, context: Context) {
        //
    }
    
    typealias UIViewControllerType = ScoreBoardVC

}
