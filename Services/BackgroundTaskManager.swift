import Foundation
import BackgroundTasks
import Combine
import UIKit

class BackgroundTaskManager: ObservableObject {
    static let shared = BackgroundTaskManager()
    
    private let backgroundTaskIdentifier = "com.gettysburgcampus.eventrefresh"
    private let icsParser = ICSParser()
    
    private init() {}
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundTask(task as! BGAppRefreshTask)
        }
    }
    
    func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600) // 1 hour from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background refresh scheduled successfully")
        } catch {
            print("Failed to schedule background refresh: \(error)")
        }
    }
    
    private func handleBackgroundTask(_ task: BGAppRefreshTask) {
        // Schedule the next background refresh
        scheduleBackgroundRefresh()
        
        // Create a task to track background execution
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Perform the background work
        Task {
            await icsParser.fetchEvents()
            task.setTaskCompleted(success: true)
        }
    }
}

// MARK: - Background Task Management

extension BackgroundTaskManager {
    func setupBackgroundTasks() {
        registerBackgroundTasks()
    }
    
    func handleAppDidEnterBackground() {
        scheduleBackgroundRefresh()
    }
} 