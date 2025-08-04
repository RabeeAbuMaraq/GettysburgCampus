import Foundation

struct CampusEvent: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let start: Date
    let end: Date
    let location: String
    let url: String?
    let organizer: String?
    let category: String?
    let eventType: String?
    
    init(id: String, title: String, description: String, start: Date, end: Date, location: String, url: String? = nil, organizer: String? = nil, category: String? = nil, eventType: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.start = start
        self.end = end
        self.location = location
        self.url = url
        self.organizer = organizer
        self.category = category
        self.eventType = eventType
    }
    
    // Computed properties for grouping
    var isToday: Bool {
        Calendar.current.isDateInToday(start)
    }
    
    var isThisWeek: Bool {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let weekEnd = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
        return start >= weekStart && start <= weekEnd
    }
    
    var isLater: Bool {
        !isToday && !isThisWeek
    }
    
    // Formatting helpers
    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: start)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: start)
    }
    
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: start)
    }
}

// MARK: - Event Grouping
enum EventGroup: String, CaseIterable {
    case today = "Today"
    case thisWeek = "This Week"
    case later = "Later"
    
    var icon: String {
        switch self {
        case .today: return "calendar.badge.clock"
        case .thisWeek: return "calendar"
        case .later: return "calendar.badge.plus"
        }
    }
}