import Foundation
import SwiftUI
import Combine

/// Centralized app state that holds all services and shared state.
/// Use as @EnvironmentObject in views.
@MainActor
final class AppState: ObservableObject {
    // MARK: - Services
    let eventsService = EventsService.shared
    let newsService = NewsService.shared
    let diningRepository = DiningRepository()
    let authService = AuthService.shared
    let userManager = UserManager.shared
    
    // MARK: - Tab Selection
    @Published var selectedTab: Int = 0
    
    // MARK: - Initialization
    init() {
        // Services will auto-load on init
        print("✅ AppState initialized")
    }
    
    // MARK: - Navigation Helpers
    func switchToTab(_ tab: AppTab) {
        selectedTab = tab.rawValue
    }
}

// MARK: - App Tabs
enum AppTab: Int, CaseIterable {
    case home = 0
    case events = 1
    case dining = 2
    case map = 3
    case more = 4
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .events: return "Events"
        case .dining: return "Dining"
        case .map: return "Map"
        case .more: return "More"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .events: return "calendar"
        case .dining: return "fork.knife"
        case .map: return "map.fill"
        case .more: return "ellipsis"
        }
    }
}

