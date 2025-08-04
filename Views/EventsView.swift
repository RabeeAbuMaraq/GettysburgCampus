import SwiftUI

struct EventsView: View {
    @StateObject private var eventsService = EventsService.shared
    @State private var selectedEvent: CampusEvent?
    @State private var showingEventDetail = false
    @State private var selectedFilter: EventFilter = .all
    @State private var isRefreshing = false
    @State private var animateCards = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background matching website
                LinearGradient(
                    colors: [
                        Color(hex: "#fff7ed"),
                        Color(hex: "#f8fafc")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        HeaderSection()
                        
                        // Filter Controls
                        FilterControlsSection(
                            selectedFilter: $selectedFilter,
                            onFilterChange: { filter in
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedFilter = filter
                                    animateCards = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        animateCards = true
                                    }
                                }
                            }
                        )
                        
                        // Refresh and Status
                        RefreshSection(
                            isRefreshing: $isRefreshing,
                            lastUpdated: eventsService.lastUpdated,
                            onRefresh: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    isRefreshing = true
                                }
                                eventsService.refreshEvents()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        isRefreshing = false
                                    }
                                }
                            }
                        )
                        
                        // Events Content
                        EventsContentSection(
                            eventsService: eventsService,
                            selectedFilter: selectedFilter,
                            animateCards: animateCards,
                            onEventTap: { event in
                                selectedEvent = event
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    showingEventDetail = true
                                }
                            }
                        )
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingEventDetail) {
            if let event = selectedEvent {
                EventDetailModal(event: event)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                animateCards = true
            }
        }
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 16) {
            // Title with gradient text effect
            HStack {
                Text("Campus")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1f2937"))
                
                Text("Events")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#CC4E00"), Color(hex: "#043B82")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            // Description
            Text("Discover what's happening on campus. From academic lectures to social gatherings, stay connected with the Gettysburg community.")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(hex: "#6b7280"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, 20)
        .padding(.bottom, 32)
    }
}

// MARK: - Filter Controls Section
struct FilterControlsSection: View {
    @Binding var selectedFilter: EventFilter
    let onFilterChange: (EventFilter) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(EventFilter.allCases, id: \.self) { filter in
                FilterButton(
                    filter: filter,
                    isSelected: selectedFilter == filter,
                    onTap: { onFilterChange(filter) }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let filter: EventFilter
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(filter.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .white : Color(hex: "#374151"))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [Color(hex: "#CC4E00"), Color(hex: "#043B82")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            Color.white
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? Color.clear : Color(hex: "#d1d5db"),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isSelected ? Color(hex: "#CC4E00").opacity(0.3) : Color.black.opacity(0.05),
                    radius: isSelected ? 12 : 4,
                    x: 0,
                    y: isSelected ? 6 : 2
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Refresh Section
struct RefreshSection: View {
    @Binding var isRefreshing: Bool
    let lastUpdated: Date?
    let onRefresh: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: onRefresh) {
                HStack(spacing: 8) {
                    if isRefreshing {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(Color(hex: "#CC4E00"))
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#374151"))
                    }
                    
                    Text("Refresh")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#374151"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.8))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#d1d5db"), lineWidth: 1)
                )
            }
            .disabled(isRefreshing)
            
            if let lastUpdated = lastUpdated {
                Text("Last updated: \(lastUpdated.formatted(.dateTime.month().day().hour().minute()))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#6b7280"))
                    .padding(.leading, 12)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
}

// MARK: - Events Content Section
struct EventsContentSection: View {
    @ObservedObject var eventsService: EventsService
    let selectedFilter: EventFilter
    let animateCards: Bool
    let onEventTap: (CampusEvent) -> Void
    
    var filteredEvents: [CampusEvent] {
        let now = Date()
        let oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: now) ?? now
        
        var events = eventsService.events.filter { event in
            event.start >= now && event.start <= oneMonthFromNow
        }
        
        switch selectedFilter {
        case .all:
            break
        case .today:
            events = events.filter { Calendar.current.isDateInToday($0.start) }
        case .thisWeek:
            events = events.filter { event in
                let calendar = Calendar.current
                let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
                let weekEnd = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
                return event.start >= weekStart && event.start <= weekEnd
            }
        }
        
        return events.sorted { $0.start < $1.start }
    }
    
    var body: some View {
        Group {
            if eventsService.isLoading {
                LoadingView()
            } else if filteredEvents.isEmpty {
                EmptyStateView(filter: selectedFilter)
            } else {
                EventsListView(
                    events: filteredEvents,
                    animateCards: animateCards,
                    onEventTap: onEventTap
                )
            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Custom loading spinner
            ZStack {
                Circle()
                    .stroke(Color(hex: "#f3f4f6"), lineWidth: 4)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#CC4E00"), Color(hex: "#043B82")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: true)
            }
            
            Text("Loading campus events...")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(hex: "#6b7280"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let filter: EventFilter
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#d1d5db"))
            
            Text("No events found")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "#1f2937"))
            
            Text("There are no upcoming events matching your current filter.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "#6b7280"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - Events List View
struct EventsListView: View {
    let events: [CampusEvent]
    let animateCards: Bool
    let onEventTap: (CampusEvent) -> Void
    
    var groupedEvents: [String: [CampusEvent]] {
        Dictionary(grouping: events) { event in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: event.start)
        }
    }
    
    var sortedDates: [String] {
        groupedEvents.keys.sorted()
    }
    
    var body: some View {
        LazyVStack(spacing: 32) {
            ForEach(Array(sortedDates.enumerated()), id: \.element) { index, date in
                if let eventsForDate = groupedEvents[date] {
                    EventDateGroup(
                        date: date,
                        events: eventsForDate,
                        animateCards: animateCards,
                        delay: Double(index) * 0.1,
                        onEventTap: onEventTap
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
    }
}

// MARK: - Event Date Group
struct EventDateGroup: View {
    let date: String
    let events: [CampusEvent]
    let animateCards: Bool
    let delay: Double
    let onEventTap: (CampusEvent) -> Void
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let dateObj = formatter.date(from: date) {
            formatter.dateFormat = "EEE, MMM d"
            return formatter.string(from: dateObj)
        }
        return date
    }
    
    var relativeDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let dateObj = formatter.date(from: date) else { return "" }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(dateObj) {
            return "Today"
        } else if calendar.isDateInTomorrow(dateObj) {
            return "Tomorrow"
        } else {
            let days = calendar.dateComponents([.day], from: Date(), to: dateObj).day ?? 0
            if days > 0 {
                return "In \(days) days"
            } else {
                return "\(abs(days)) days ago"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Date header
            HStack(spacing: 12) {
                Text(formattedDate)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#CC4E00"), Color(hex: "#043B82")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                
                Text(relativeDate)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#6b7280"))
                
                Spacer()
                
                Text("\(events.count) event\(events.count > 1 ? "s" : "")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#9ca3af"))
            }
            
            // Events grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                    EventCard(
                        event: event,
                        animateCards: animateCards,
                        delay: delay + Double(index) * 0.05,
                        onTap: { onEventTap(event) }
                    )
                }
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: animateCards)
    }
}

// MARK: - Event Card
struct EventCard: View {
    let event: CampusEvent
    let animateCards: Bool
    let delay: Double
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Time and duration
                HStack {
                    Text(formatTime(event.start))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#CC4E00"))
                    
                    Text("•")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#CC4E00"))
                    
                    Text(formatDuration(event.start, event.end))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#CC4E00"))
                    
                    Spacer()
                }
                
                // Title
                Text(event.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#1f2937"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Location
                if !event.location.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#043B82"))
                        
                        Text(event.location)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#043B82"))
                            .lineLimit(1)
                    }
                }
                
                // Description preview
                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#6b7280"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Tap indicator
                HStack {
                    Text("Tap to view details")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "#9ca3af"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "#9ca3af"))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(
                color: Color.black.opacity(0.08),
                radius: 12,
                x: 0,
                y: 6
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(animateCards ? 1 : 0)
            .offset(y: animateCards ? 0 : 20)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: animateCards)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ start: Date, _ end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Event Detail Modal
struct EventDetailModal: View {
    let event: CampusEvent
    @Environment(\.dismiss) private var dismiss
    @State private var animateIn = false
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Modal content
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color(hex: "#d1d5db"))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title
                        Text(event.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "#1f2937"))
                            .multilineTextAlignment(.leading)
                        
                        // Time and location
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "clock")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#CC4E00"))
                                
                                Text("\(formatDateTime(event.start)) • \(formatDuration(event.start, event.end))")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#374151"))
                            }
                            
                            if !event.location.isEmpty {
                                HStack(spacing: 8) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "#043B82"))
                                    
                                    Text(event.location)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(hex: "#374151"))
                                }
                            }
                        }
                        
                        // Description
                        if !event.description.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(hex: "#043B82"))
                                    
                                    Text("Event Description")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color(hex: "#1f2937"))
                                }
                                
                                Text(event.description)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#6b7280"))
                                    .lineSpacing(4)
                            }
                            .padding(16)
                            .background(Color(hex: "#f9fafb"))
                            .cornerRadius(12)
                        }
                        
                        // Action buttons
                        VStack(spacing: 12) {
                            if let url = event.url {
                                Link(destination: URL(string: url) ?? URL(string: "https://engage.gettysburg.edu")!) {
                                    HStack {
                                        Image(systemName: "arrow.up.right.square")
                                            .font(.system(size: 16, weight: .medium))
                                        Text("Register on Engage")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(hex: "#043B82"), Color(hex: "#1e40af")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                }
                            }
                            
                            Button("Close") {
                                dismiss()
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#374151"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#d1d5db"), lineWidth: 1)
                            )
                        }
                    }
                    .padding(24)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
            )
            .padding(.horizontal, 20)
            .offset(y: animateIn ? 0 : 600)
            .opacity(animateIn ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateIn = true
            }
        }
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ start: Date, _ end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes > 0 ? "\(minutes)m" : "")"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Event Filter
enum EventFilter: CaseIterable {
    case all, today, thisWeek
    
    var title: String {
        switch self {
        case .all: return "All Events"
        case .today: return "Today"
        case .thisWeek: return "This Week"
        }
    }
}
