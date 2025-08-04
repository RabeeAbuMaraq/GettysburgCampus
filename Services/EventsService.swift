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
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let jsonURL = "https://gburgcampus.app/events.json"
    private var cancellables = Set<AnyCancellable>()
    
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
            .map(\.data)
            .decode(type: EventsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ Error loading events: \(error)")
                        self.errorMessage = "Failed to load events: \(error.localizedDescription)"
                    }
                },
                receiveValue: { response in
                    print("📊 Received \(response.events.count) events from API")
                    let convertedEvents = response.events.compactMap { self.convertToCampusEvent($0) }
                    print("✅ Converted \(convertedEvents.count) events successfully")
                    self.events = convertedEvents.sorted { $0.start < $1.start }
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
        loadEvents()
    }
} 