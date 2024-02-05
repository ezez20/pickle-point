//
//  pickle_pointApp.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/11/23.
//

import SwiftUI

@main
struct pickle_pointApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }

}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    static var orientationLock = UIInterfaceOrientationMask.portrait {
    
        didSet {
//            if #available(iOS 16.0, *) {
//                UIApplication.shared.connectedScenes.forEach { scene in
//                    if let windowScene = scene as? UIWindowScene {
//                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationLock))
//                    }
//                }
//                UIViewController.attemptRotationToDeviceOrientation()
//              
//            } else {
//                if orientationLock == .landscape {
//                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
//                } else {
//                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
//                }
//            }
        }
    }

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("didFinishLaunchingWithOptions")
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
