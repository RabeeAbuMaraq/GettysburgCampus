//
//  GettysburgCampusApp.swift
//  GettysburgCampus
//
//  Created by Rabee AbuMaraq on 7/18/25.
//

import SwiftUI
import BackgroundTasks
import UIKit

@main
struct GettysburgCampusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Register background tasks
        BackgroundTaskManager.shared.setupBackgroundTasks()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Schedule background refresh when app goes to background
        BackgroundTaskManager.shared.handleAppDidEnterBackground()
    }
}
