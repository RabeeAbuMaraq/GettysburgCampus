import Foundation
import Combine

// MARK: - JSON Response Models
struct EventsResponse: Codable {
    let events: [EventJSON]
    let metadata: EventsMetadata
}

struct EventJSON: Codable {
    let title: String
    let start: String
    let end: String
    let location: String
    let description: String
    let url: String
}

struct EventsMetadata: Codable {
    let lastUpdated: String
    let totalEvents: Int
    let source: String
    let syncDuration: String
}

// MARK: - Events Service
class EventsService: ObservableObject {
    static let shared = EventsService()
    
    @Published var events: [CampusEvent] = []
    @Published var filteredEvents: [CampusEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    private let jsonURL = "https://gburgcampus.app/events.json"
    private var cancellables = Set<AnyCancellable>()
    
    // Filter states
    @Published var selectedTimeFilter: TimeFilter = .all
    @Published var selectedCategoryFilter: String?
    @Published var searchText = ""
    
    // Available categories for filtering
    @Published var availableCategories: [String] = []
    
    init() {
        loadEvents()
    }
    
    // MARK: - Computed Properties
    var todayEventsCount: Int {
        events.filter { $0.isToday }.count
    }
    
    var upcomingEventsCount: Int {
        events.filter { $0.start > Date() }.count
    }
    
    func loadEvents() {
        print("🔄 EventsService: Starting to load events from \(jsonURL)")
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: jsonURL) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: EventsResponse.self, decoder: JSONDecoder())
            .map { response in
                print("📊 EventsService: Received \(response.events.count) events from API")
                self.lastUpdated = ISO8601DateFormatter().date(from: response.metadata.lastUpdated)
                let convertedEvents = response.events.compactMap { self.convertToCampusEvent($0) }
                print("✅ EventsService: Successfully converted \(convertedEvents.count) events")
                return convertedEvents
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        if case .failure(let error) = completion {
                            print("❌ EventsService: Failed to load events - \(error.localizedDescription)")
                            self.errorMessage = "Failed to load events: \(error.localizedDescription)"
                        }
                    }
                },
                receiveValue: { events in
                    DispatchQueue.main.async {
                        print("🎉 EventsService: Setting \(events.count) events")
                        self.events = events.sorted { $0.start < $1.start }
                        self.extractCategories()
                        self.applyFilters()
                        print("📱 EventsService: Filtered events count: \(self.filteredEvents.count)")
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func convertToCampusEvent(_ jsonEvent: EventJSON) -> CampusEvent? {
        let dateFormatter = ISO8601DateFormatter()
        
        guard let startDate = dateFormatter.date(from: jsonEvent.start),
              let endDate = dateFormatter.date(from: jsonEvent.end) else {
            return nil
        }
        
        // Extract location name and coordinates
        let locationParts = jsonEvent.location.components(separatedBy: ", ")
        let locationName = locationParts.first ?? jsonEvent.location
        let coordinates = locationParts.count > 1 ? locationParts.last : nil
        
        // Clean up description (remove markdown separators)
        let cleanDescription = jsonEvent.description
            .replacingOccurrences(of: "\\n---\\n", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Generate unique ID
        let id = "\(jsonEvent.title)_\(startDate.timeIntervalSince1970)"
        
        return CampusEvent(
            id: id,
            title: jsonEvent.title,
            description: cleanDescription,
            start: startDate,
            end: endDate,
            location: locationName,
            url: jsonEvent.url,
            organizer: nil, // Not available in JSON
            category: extractCategory(from: jsonEvent.title),
            eventType: extractEventType(from: jsonEvent.title)
        )
    }
    
    private func extractCategory(from title: String) -> String? {
        let lowercasedTitle = title.lowercased()
        
        if lowercasedTitle.contains("soccer") || lowercasedTitle.contains("lacrosse") || lowercasedTitle.contains("basketball") {
            return "Sports"
        } else if lowercasedTitle.contains("mass") || lowercasedTitle.contains("chapel") || lowercasedTitle.contains("worship") {
            return "Religious"
        } else if lowercasedTitle.contains("concert") || lowercasedTitle.contains("music") || lowercasedTitle.contains("choir") {
            return "Music"
        } else if lowercasedTitle.contains("meeting") || lowercasedTitle.contains("council") {
            return "Meetings"
        } else if lowercasedTitle.contains("dance") || lowercasedTitle.contains("swing") {
            return "Social"
        } else if lowercasedTitle.contains("graduation") || lowercasedTitle.contains("commencement") {
            return "Academic"
        }
        
        return nil
    }
    
    private func extractEventType(from title: String) -> String? {
        let lowercasedTitle = title.lowercased()
        
        if lowercasedTitle.contains("practice") || lowercasedTitle.contains("rehearsal") {
            return "Practice"
        } else if lowercasedTitle.contains("meeting") {
            return "Meeting"
        } else if lowercasedTitle.contains("concert") || lowercasedTitle.contains("performance") {
            return "Performance"
        } else if lowercasedTitle.contains("championship") || lowercasedTitle.contains("game") {
            return "Game"
        }
        
        return nil
    }
    
    private func extractCategories() {
        let categories = Set(events.compactMap { $0.category })
        availableCategories = Array(categories).sorted()
    }
    
    func applyFilters() {
        DispatchQueue.main.async {
            var filtered = self.events
            
            // Apply time filter
            switch self.selectedTimeFilter {
            case .today:
                filtered = filtered.filter { $0.isToday }
            case .thisWeek:
                filtered = filtered.filter { $0.isThisWeek }
            case .upcoming:
                filtered = filtered.filter { $0.start > Date() }
            case .all:
                break
            }
            
            // Apply category filter
            if let category = self.selectedCategoryFilter {
                filtered = filtered.filter { $0.category == category }
            }
            
            // Apply search filter
            if !self.searchText.isEmpty {
                filtered = filtered.filter { event in
                    event.title.localizedCaseInsensitiveContains(self.searchText) ||
                    event.location.localizedCaseInsensitiveContains(self.searchText) ||
                    (event.description.localizedCaseInsensitiveContains(self.searchText))
                }
            }
            
            print("🔍 EventsService: Applied filters - \(filtered.count) events after filtering")
            self.filteredEvents = filtered
        }
    }
    
    func refreshEvents() {
        loadEvents()
    }
    
    // MARK: - Favorites Management
    private let favoritesKey = "favorite_events"
    
    func toggleFavorite(for eventId: String) {
        var favorites = getFavorites()
        if favorites.contains(eventId) {
            favorites.remove(eventId)
        } else {
            favorites.insert(eventId)
        }
        UserDefaults.standard.set(Array(favorites), forKey: favoritesKey)
    }
    
    func isFavorite(_ eventId: String) -> Bool {
        let favorites = getFavorites()
        return favorites.contains(eventId)
    }
    
    private func getFavorites() -> Set<String> {
        let favorites = UserDefaults.standard.array(forKey: favoritesKey) as? [String] ?? []
        return Set(favorites)
    }
}

// MARK: - Time Filter
enum TimeFilter: String, CaseIterable {
    case all = "All"
    case today = "Today"
    case thisWeek = "This Week"
    case upcoming = "Upcoming"
    
    var icon: String {
        switch self {
        case .all: return "calendar"
        case .today: return "calendar.badge.clock"
        case .thisWeek: return "calendar.badge.plus"
        case .upcoming: return "clock.arrow.circlepath"
        }
    }
} 