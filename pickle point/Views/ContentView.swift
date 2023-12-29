//
//  ContentView.swift
//  pickle point
//
//  Created by Ezra Yeoh on 4/11/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @StateObject private var cameraModel = CameraModel()
    @StateObject var scoreBoardManager = ScoreBoardManager()
    @StateObject var watchKitManager = WatchKitManager_iOS()
    @StateObject var viewRecorder = ViewRecorder()
    
    @State private var shareVideo = false
    @State private var videoCurrentlySaving = false

    var body: some View {

        ZStack {
            RecordingView(cameraModel: cameraModel, scoreBoardManager: scoreBoardManager, watchKitManager: watchKitManager, videoRecorder: viewRecorder)
                .ignoresSafeArea(.all, edges: .all)
            
            ControlsView(sbm: scoreBoardManager, vmWKM: watchKitManager, cm: cameraModel, viewRecorder: viewRecorder)
                .ignoresSafeArea(.all, edges: .bottom)
        }
        
    }

//    private func addItem() {
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
