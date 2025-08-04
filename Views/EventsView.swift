import SwiftUI

struct EventsView: View {
    @StateObject private var eventsService = EventsService()
    @State private var selectedEvent: CampusEvent?
    @State private var showingEventDetail = false
    @State private var showingFavoritesOnly = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                if eventsService.isLoading && eventsService.filteredEvents.isEmpty {
                    LoadingView()
                } else if eventsService.filteredEvents.isEmpty {
                    EmptyStateView(
                        showingFavoritesOnly: showingFavoritesOnly,
                        onRefresh: { eventsService.refreshEvents() }
                    )
                } else {
                    VStack(spacing: 0) {
                        // Search Bar
                        SearchBar(text: $searchText)
                            .onChange(of: searchText) { _ in
                                eventsService.searchText = searchText
                                eventsService.applyFilters()
                            }
                        
                        // Filter Controls
                        FilterControlsView(eventsService: eventsService)
                        
                        // Favorites Toggle & Event Count
                        HStack {
                            FavoritesToggle(
                                isActive: $showingFavoritesOnly,
                                onToggle: { showingFavoritesOnly.toggle() }
                            )
                            
                            Spacer()
                            
                            EventCountView(count: eventsService.filteredEvents.count)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Events List
                        EventsListView(
                            events: showingFavoritesOnly ? 
                                eventsService.filteredEvents.filter { eventsService.isFavorite($0.id) } : 
                                eventsService.filteredEvents,
                            eventsService: eventsService,
                            onEventTap: { event in
                                selectedEvent = event
                                showingEventDetail = true
                            }
                        )
                    }
                }
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    RefreshButton(
                        isLoading: eventsService.isLoading,
                        onRefresh: { eventsService.refreshEvents() }
                    )
                }
            }
            .refreshable {
                eventsService.refreshEvents()
            }
        }
        .sheet(isPresented: $showingEventDetail) {
            if let event = selectedEvent {
                EventDetailView(event: event)
            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color.primaryAccent)
            
            Text("Loading events...")
                .bodyText()
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let showingFavoritesOnly: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: showingFavoritesOnly ? "heart.slash" : "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(Color.textSecondary)
            
            Text(showingFavoritesOnly ? "No Favorite Events" : "No Events Available")
                .sectionHeader()
            
            Text(showingFavoritesOnly ? 
                "Add some events to your favorites to see them here" : 
                "Check back later for upcoming campus events")
                .bodyText()
                .multilineTextAlignment(.center)
            
            if !showingFavoritesOnly {
                Button("Refresh Events") {
                    onRefresh()
                }
                .modernButton(.primary)
            }
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.textSecondary)
            
            TextField("Search events...", text: $text)
                .font(.system(size: 16))
                .foregroundColor(Color.textPrimary)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.subtleBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

// MARK: - Filter Controls View
struct FilterControlsView: View {
    @ObservedObject var eventsService: EventsService
    
    var body: some View {
        VStack(spacing: 16) {
            // Time Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TimeFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.rawValue,
                            icon: filter.icon,
                            isSelected: eventsService.selectedTimeFilter == filter
                        ) {
                            eventsService.selectedTimeFilter = filter
                            eventsService.applyFilters()
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Category Filter
            if !eventsService.availableCategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "All Categories",
                            isSelected: eventsService.selectedCategoryFilter == nil
                        ) {
                            eventsService.selectedCategoryFilter = nil
                            eventsService.applyFilters()
                        }
                        
                        ForEach(eventsService.availableCategories, id: \.self) { category in
                            FilterChip(
                                title: category,
                                isSelected: eventsService.selectedCategoryFilter == category
                            ) {
                                eventsService.selectedCategoryFilter = category
                                eventsService.applyFilters()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String, icon: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : Color.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.primaryAccent : Color.cardBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.primaryAccent : Color.subtleBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Favorites Toggle
struct FavoritesToggle: View {
    @Binding var isActive: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(systemName: isActive ? "heart.fill" : "heart")
                    .foregroundColor(isActive ? .red : Color.textSecondary)
                
                Text(isActive ? "Favorites" : "All Events")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.cardBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.subtleBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Event Count View
struct EventCountView: View {
    let count: Int
    
    var body: some View {
        Text("\(count) events")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color.textSecondary)
    }
}

// MARK: - Events List View
struct EventsListView: View {
    let events: [CampusEvent]
    @ObservedObject var eventsService: EventsService
    let onEventTap: (CampusEvent) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(events) { event in
                    ModernEventCard(
                        event: event,
                        isFavorite: eventsService.isFavorite(event.id),
                        onFavoriteToggle: {
                            eventsService.toggleFavorite(for: event.id)
                        },
                        onTap: { onEventTap(event) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Modern Event Card
struct ModernEventCard: View {
    let event: CampusEvent
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with title and favorite button
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 12) {
                            // Date and time
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.primaryAccent)
                                
                                Text(event.formattedDateTime)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.primaryAccent)
                            }
                            
                            // Duration
                            if event.start != event.end {
                                HStack(spacing: 4) {
                                    Image(systemName: "timer")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.textSecondary)
                                    
                                    Text(formatDuration(from: event.start, to: event.end))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.textSecondary)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: onFavoriteToggle) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 20))
                            .foregroundColor(isFavorite ? .red : Color.textSecondary)
                    }
                }
                
                // Category and Event Type badges
                if event.category != nil || event.eventType != nil {
                    HStack(spacing: 8) {
                        if let category = event.category {
                            CategoryBadge(text: category, color: Color.primaryAccent)
                        }
                        
                        if let eventType = event.eventType {
                            CategoryBadge(text: eventType, color: Color.textSecondary)
                        }
                    }
                }
                
                // Location
                if !event.location.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.textSecondary)
                        
                        Text(event.location)
                            .font(.system(size: 14))
                            .foregroundColor(Color.textSecondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding(20)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.subtleBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDuration(from start: Date, to end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Category Badge
struct CategoryBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

// MARK: - Refresh Button
struct RefreshButton: View {
    let isLoading: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        Button(action: onRefresh) {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(Color.primaryAccent)
            } else {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(Color.primaryAccent)
            }
        }
        .disabled(isLoading)
    }
}

// MARK: - Event Detail View
struct EventDetailView: View {
    let event: CampusEvent
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(event.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.textPrimary)
                        
                        HStack(spacing: 16) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.primaryAccent)
                                
                                Text(event.formattedDateTime)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.primaryAccent)
                            }
                            
                            if event.start != event.end {
                                HStack(spacing: 6) {
                                    Image(systemName: "timer")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.textSecondary)
                                    
                                    Text(formatDuration(from: event.start, to: event.end))
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color.textSecondary)
                                }
                            }
                        }
                    }
                    
                    // Category and Event Type
                    if event.category != nil || event.eventType != nil {
                        HStack(spacing: 8) {
                            if let category = event.category {
                                CategoryBadge(text: category, color: Color.primaryAccent)
                            }
                            
                            if let eventType = event.eventType {
                                CategoryBadge(text: eventType, color: Color.textSecondary)
                            }
                        }
                    }
                    
                    // Location
                    if !event.location.isEmpty {
                        DetailSection(
                            icon: "location.fill",
                            title: "Location",
                            content: event.location
                        )
                    }
                    
                    // Description
                    if !event.description.isEmpty {
                        DetailSection(
                            icon: "text.alignleft",
                            title: "Description",
                            content: event.description
                        )
                    }
                    
                    // URL
                    if let url = event.url {
                        DetailSection(
                            icon: "link",
                            title: "More Info",
                            content: "View Event Details",
                            isLink: true,
                            url: url
                        )
                    }
                }
                .padding(20)
            }
            .background(Color.background.ignoresSafeArea())
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color.primaryAccent)
                }
            }
        }
    }
    
    private func formatDuration(from start: Date, to end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Detail Section
struct DetailSection: View {
    let icon: String
    let title: String
    let content: String
    let isLink: Bool
    let url: String?
    
    init(icon: String, title: String, content: String, isLink: Bool = false, url: String? = nil) {
        self.icon = icon
        self.title = title
        self.content = content
        self.isLink = isLink
        self.url = url
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.textPrimary)
            
            if isLink, let url = url {
                Link(content, destination: URL(string: url) ?? URL(string: "https://engage.gettysburg.edu")!)
                    .font(.system(size: 16))
                    .foregroundColor(Color.primaryAccent)
            } else {
                Text(content)
                    .font(.system(size: 16))
                    .foregroundColor(Color.textSecondary)
                    .lineSpacing(4)
            }
        }
    }
}
