import Foundation
import Combine

// MARK: - Custom Errors
enum EventsError: Error {
    case notFound
    case invalidResponse
}

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
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    private let jsonURL = "https://gburgcampus.app/events.json"
    private var cancellables = Set<AnyCancellable>()
    private var retryCount = 0
    private let maxRetries = 2
    private var retryTimer: AnyCancellable?
    
    init() {
        loadEvents()
    }
    
    func loadEvents() {
        print("🔄 Loading events from: \(jsonURL)")
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: jsonURL) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                // Check for HTTP errors
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                // Handle 404 and other HTTP errors
                if httpResponse.statusCode == 404 {
                    print("⚠️ Events API endpoint not found (404). Using fallback.")
                    throw EventsError.notFound
                }
                
                if httpResponse.statusCode != 200 {
                    print("⚠️ Events API returned status code: \(httpResponse.statusCode)")
                    throw URLError(.badServerResponse)
                }
                
                // Check if we received HTML instead of JSON
                if let contentType = httpResponse.allHeaderFields["Content-Type"] as? String,
                   contentType.contains("text/html") {
                    print("⚠️ Events API returned HTML instead of JSON")
                    throw EventsError.invalidResponse
                }
                
                // Check if the data starts with '<' (HTML)
                if let firstChar = data.first, firstChar == 60 { // ASCII '<'
                    print("⚠️ Received HTML instead of JSON from events API")
                    throw EventsError.invalidResponse
                }
                
                return data
            }
            .decode(type: EventsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ Error loading events: \(error)")
                        
                        // Retry logic for transient errors
                        if self.retryCount < self.maxRetries,
                           !(error is EventsError) { // Don't retry for known errors (404, HTML response)
                            self.retryCount += 1
                            let delay = Double(self.retryCount) * 2.0 // Exponential backoff
                            print("🔄 Retrying in \(delay) seconds (attempt \(self.retryCount + 1)/\(self.maxRetries + 1))")
                            
                            self.retryTimer = Timer.publish(every: delay, on: .main, in: .common)
                                .autoconnect()
                                .first()
                                .sink { _ in
                                    self.loadEvents()
                                }
                            return
                        }
                        
                        // Reset retry count for next manual refresh
                        self.retryCount = 0
                        
                        // Provide user-friendly error messages
                        if let eventsError = error as? EventsError {
                            switch eventsError {
                            case .notFound:
                                self.errorMessage = "Events feed is currently unavailable"
                                self.loadMockEvents() // Load fallback data
                            case .invalidResponse:
                                self.errorMessage = "Events feed is temporarily offline"
                                self.loadMockEvents() // Load fallback data
                            }
                        } else {
                            self.errorMessage = "Unable to load events. Please try again later."
                            self.loadMockEvents() // Load fallback data
                        }
                    } else {
                        // Success - reset retry count
                        self.retryCount = 0
                    }
                },
                receiveValue: { response in
                    print("📊 Received \(response.events.count) events from API")
                    let convertedEvents = response.events.compactMap { self.convertToCampusEvent($0) }
                    print("✅ Converted \(convertedEvents.count) events successfully")
                    
                    // Filter events to only show those within one month from now
                    let now = Date()
                    let oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: now) ?? now
                    
                    self.events = convertedEvents
                        .filter { event in
                            event.start >= now && event.start <= oneMonthFromNow
                        }
                        .sorted { $0.start < $1.start }
                    
                    print("📅 Filtered to \(self.events.count) events within one month")
                    
                    self.lastUpdated = ISO8601DateFormatter().date(from: response.metadata.lastUpdated)
                }
            )
            .store(in: &cancellables)
    }
    
    private func convertToCampusEvent(_ jsonEvent: EventJSON) -> CampusEvent? {
        // Create a date formatter that can handle the ISO8601 format
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // Try to parse the dates
        guard let startDate = formatter.date(from: jsonEvent.start) else {
            print("❌ Failed to parse start date: \(jsonEvent.start)")
            return nil
        }
        
        guard let endDate = formatter.date(from: jsonEvent.end) else {
            print("❌ Failed to parse end date: \(jsonEvent.end)")
            return nil
        }
        
        // Extract location name (remove coordinates)
        let locationParts = jsonEvent.location.components(separatedBy: ", ")
        let locationName = locationParts.first ?? jsonEvent.location
        
        // Clean up description
        let cleanDescription = jsonEvent.description
            .replacingOccurrences(of: "\\n---\\n", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Generate unique ID
        let id = "\(jsonEvent.title)_\(startDate.timeIntervalSince1970)"
        
        let event = CampusEvent(
            id: id,
            title: jsonEvent.title,
            description: cleanDescription,
            start: startDate,
            end: endDate,
            location: locationName,
            url: jsonEvent.url,
            organizer: nil,
            category: nil,
            eventType: nil
        )
        
        print("✅ Created event: \(event.title) at \(event.start)")
        return event
    }
    
    func refreshEvents() {
        retryCount = 0 // Reset retry count on manual refresh
        retryTimer?.cancel() // Cancel any pending retry
        loadEvents()
    }
    
    // MARK: - Fallback Mock Data
    private func loadMockEvents() {
        print("📦 Loading mock/fallback events")
        
        // Create some sample upcoming events as fallback
        let calendar = Calendar.current
        let now = Date()
        
        // Sample events for the next few days
        let mockEventsData: [(title: String, daysOffset: Int, duration: TimeInterval, location: String, description: String)] = [
            ("Campus Tour", 1, 2 * 3600, "Admissions Office", "Join us for a guided tour of the Gettysburg College campus."),
            ("Coffee & Conversation", 2, 1.5 * 3600, "Servo", "Informal gathering for students and faculty."),
            ("Study Session", 3, 3 * 3600, "Musselman Library", "Group study session for finals preparation."),
            ("Guest Lecture", 5, 1 * 3600, "Science Center", "Special guest speaker on environmental science."),
            ("Community Service Day", 7, 4 * 3600, "Campus Center", "Volunteer opportunities in the local community.")
        ]
        
        var mockEvents: [CampusEvent] = []
        
        for (title, daysOffset, duration, location, description) in mockEventsData {
            if let startDate = calendar.date(byAdding: .day, value: daysOffset, to: now),
               let endDate = calendar.date(byAdding: .second, value: Int(duration), to: startDate) {
                let event = CampusEvent(
                    id: "mock_\(title.replacingOccurrences(of: " ", with: "_"))_\(daysOffset)",
                    title: title,
                    description: description,
                    start: startDate,
                    end: endDate,
                    location: location,
                    url: "https://www.gettysburg.edu",
                    organizer: nil,
                    category: "General",
                    eventType: "Campus Event"
                )
                mockEvents.append(event)
            }
        }
        
        self.events = mockEvents.sorted { $0.start < $1.start }
        self.lastUpdated = Date()
        
        print("✅ Loaded \(mockEvents.count) mock events as fallback")
    }
} 