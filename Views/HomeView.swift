#if canImport(SwiftUI)
// Only define HomeHeaderView and HomeView here to avoid redeclaration
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var animateContent = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Header Section
                        HomeHeaderSection()
                        
                        // Quick Actions
                        HomeQuickActionsSection()
                        
                        // Today's Events Preview
                        if !appState.eventsService.events.isEmpty {
                            TodayEventsSection()
                        }
                        
                        // Latest News
                        NewsSection()
                        
                        // Campus Updates
                        CampusUpdatesSection()
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            withAnimation(DesignSystem.Animations.springSlow.delay(0.2)) {
                animateContent = true
            }
        }
    }
}

// MARK: - Header Section
struct HomeHeaderSection: View {
    @State private var animateHeader = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Greeting
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(greetingText)
                        .font(DesignSystem.Typography.title1)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("Here's what's happening on campus today")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Profile button
                Button(action: {
                    // Profile action
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [DesignSystem.Colors.orange, DesignSystem.Colors.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .opacity(animateHeader ? 1 : 0)
            .offset(y: animateHeader ? 0 : 20)
        }
        .padding(.top, DesignSystem.Spacing.lg)
        .onAppear {
            withAnimation(DesignSystem.Animations.spring.delay(0.3)) {
                animateHeader = true
            }
        }
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
}

// MARK: - Quick Actions Section
struct HomeQuickActionsSection: View {
    @State private var animateActions = false
    
    let quickActions = [
        QuickAction(
            icon: "fork.knife",
            title: "Dining",
            subtitle: "Check hours & menus",
            color: DesignSystem.Colors.orange,
            destination: .dining
        ),
        QuickAction(
            icon: "calendar",
            title: "Events",
            subtitle: "View campus events",
            color: DesignSystem.Colors.success,
            destination: .events
        ),
        QuickAction(
            icon: "calendar.badge.clock",
            title: "Calendar",
            subtitle: "Monthly view",
            color: DesignSystem.Colors.purple,
            destination: .calendar
        ),
        QuickAction(
            icon: "map.fill",
            title: "Campus Map",
            subtitle: "Find your way around",
            color: DesignSystem.Colors.warning,
            destination: .map
        ),
        QuickAction(
            icon: "bus.fill",
            title: "Shuttle",
            subtitle: "Next: 4:25 PM",
            color: DesignSystem.Colors.blue,
            destination: .shuttle
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Quick Actions")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.md) {
                ForEach(Array(quickActions.enumerated()), id: \.offset) { index, action in
                    HomeQuickActionCard(action: action)
                        .opacity(animateActions ? 1 : 0)
                        .offset(y: animateActions ? 0 : 30)
                        .animation(DesignSystem.Animations.spring.delay(Double(index) * 0.1), value: animateActions)
                }
            }
        }
        .onAppear {
            withAnimation(DesignSystem.Animations.spring.delay(0.4)) {
                animateActions = true
            }
        }
    }
}

// MARK: - Quick Action Card
struct HomeQuickActionCard: View {
    let action: QuickAction
    @State private var isPressed = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button(action: {
            // Navigate to destination
            switch action.destination {
            case .dining:
                appState.switchToTab(.dining)
            case .events:
                appState.switchToTab(.events)
            case .map:
                appState.switchToTab(.map)
            case .calendar:
                appState.switchToTab(.events)
            case .shuttle:
                // TODO: Implement shuttle feature
                break
            }
        }) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Image(systemName: action.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(action.color)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(action.title)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(action.subtitle)
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard()
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(DesignSystem.Animations.easeInOut) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Today's Events Section
struct TodayEventsSection: View {
    @EnvironmentObject var appState: AppState
    @State private var animateEvents = false
    
    // New state variables for selected event and showing detail modal
    @State private var selectedEvent: CampusEvent? = nil
    @State private var showingEventDetail = false
    
    var todayEvents: [CampusEvent] {
        appState.eventsService.events.filter { Calendar.current.isDateInToday($0.start) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Today's Events")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: EventsView()) {
                    Text("View All")
                        .font(DesignSystem.Typography.footnote.weight(.semibold))
                        .foregroundColor(DesignSystem.Colors.blue)
                }
            }
            
            if todayEvents.isEmpty {
                EmptyTodayEvents()
            } else {
                ForEach(Array(todayEvents.prefix(3).enumerated()), id: \.element.id) { index, event in
                    TodayEventCard(event: event) {
                        selectedEvent = event
                        showingEventDetail = true
                    }
                    .id("\(event.id)_\(index)")
                    .opacity(animateEvents ? 1 : 0)
                    .offset(y: animateEvents ? 0 : 20)
                    .animation(DesignSystem.Animations.spring.delay(Double(index) * 0.1), value: animateEvents)
                }
            }
        }
        .onAppear {
            withAnimation(DesignSystem.Animations.spring.delay(0.5)) {
                animateEvents = true
            }
        }
        // Present the event detail modal same as EventsView
        .sheet(isPresented: $showingEventDetail) {
            if let event = selectedEvent {
                EventDetailModal(event: event)
            }
        }
    }
}

// MARK: - Today Event Card
struct TodayEventCard: View {
    let event: CampusEvent
    // Accept onTap closure for tap action (new)
    var onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Time indicator
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text(formatTime(event.start))
                        .font(DesignSystem.Typography.footnote.weight(.semibold))
                        .foregroundColor(DesignSystem.Colors.orange)
                    
                    Text(formatDuration(event.start, event.end))
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .frame(width: 60)
                
                // Event details
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(event.title)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .lineLimit(2)
                    
                    // New subtext logic: show organizer or category or first sentence of description
                    if let subtext = eventSubtext {
                        Text(subtext)
                            .font(DesignSystem.Typography.footnote)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            .padding(DesignSystem.Spacing.lg)
            .glassCard()
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(DesignSystem.Animations.easeInOut) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    // Compute subtext from organizer, category, or first sentence of description
    private var eventSubtext: String? {
        if let organizer = event.organizer, !organizer.isEmpty {
            return organizer
        }
        if let category = event.category, !category.isEmpty {
            return category
        }
        let desc = event.description.trimmingCharacters(in: .whitespacesAndNewlines)
        if !desc.isEmpty {
            // Extract first sentence or line
            if let firstSentence = desc.split(separator: ".").first {
                return firstSentence.trimmingCharacters(in: .whitespacesAndNewlines) + "."
            } else if let firstLine = desc.split(separator: "\n").first {
                return firstLine.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                return desc
            }
        }
        return nil
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

// MARK: - Empty Today Events
struct EmptyTodayEvents: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 32))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            Text("No events today")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text("Check out upcoming events this week")
                .font(DesignSystem.Typography.footnote)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xl)
        .glassCard()
    }
}

// MARK: - Campus Updates Section
struct CampusUpdatesSection: View {
    @State private var animateUpdates = false
    
    let updates = [
        CampusUpdate(
            title: "Library Extended Hours",
            description: "The library will be open until 2 AM during finals week",
            time: "2 hours ago",
            type: .info
        ),
        CampusUpdate(
            title: "Weather Alert",
            description: "Light rain expected this afternoon. Bring an umbrella!",
            time: "4 hours ago",
            type: .warning
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Campus Updates")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            ForEach(Array(updates.enumerated()), id: \.offset) { index, update in
                CampusUpdateCard(update: update)
                    .opacity(animateUpdates ? 1 : 0)
                    .offset(y: animateUpdates ? 0 : 20)
                    .animation(DesignSystem.Animations.spring.delay(Double(index) * 0.1), value: animateUpdates)
            }
        }
        .onAppear {
            withAnimation(DesignSystem.Animations.spring.delay(0.6)) {
                animateUpdates = true
            }
        }
    }
}

// MARK: - Campus Update Card
struct CampusUpdateCard: View {
    let update: CampusUpdate
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Show update detail
        }) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Text(update.title)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    Text(update.time)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Text(update.description)
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .lineSpacing(2)
            }
            .padding(DesignSystem.Spacing.lg)
            .glassCard()
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(DesignSystem.Animations.easeInOut) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Data Models
struct QuickAction {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: QuickActionDestination
}

enum QuickActionDestination {
    case dining, events, map, shuttle, calendar
}

struct CampusUpdate {
    let title: String
    let description: String
    let time: String
    let type: UpdateType
}

enum UpdateType {
    case info, warning, success, error
}

#endif
