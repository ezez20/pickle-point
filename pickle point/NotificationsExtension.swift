//
//  NotificationsExtension.swift
//  pickle point
//
//  Created by Ezra Yeoh on 1/26/24.
//

import Foundation

extension Notification.Name {
    static let watchAppActivated = Notification.Name("watchApp.activated")
    static let watchAppDeactivated = Notification.Name("watchApp.deactivated")
    static let reloadScoreForWatch = Notification.Name("reloadScoreForWatch")
    static let startViewRecorder = Notification.Name("startViewRecorder")
    static let startCameraRecorder = Notification.Name("startCameraRecorder")
    static let updateTimer = Notification.Name("updateTimer")
    static let updateCircularProgressView = Notification.Name("updateCircularProgressView")
    static let stopViewRecorder = Notification.Name("stopViewRecorder")
    static let resetTimer = Notification.Name("resetTimer")
    static let updateVC = Notification.Name("updateVC")
    static let testSelector = Notification.Name("testSelector")
}
