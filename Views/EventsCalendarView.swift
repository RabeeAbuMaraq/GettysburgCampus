import SwiftUI

struct EventsCalendarView: View {
    @StateObject private var eventsService = EventsService.shared
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    @State private var animateCalendar = false
    
    private let calendar = Calendar.current
    private let daysInWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Header
                CalendarHeader(currentMonth: $currentMonth)
                
                // Calendar Grid
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Day headers
                    HStack(spacing: 0) {
                        ForEach(daysInWeek, id: \.self) { day in
                            Text(day)
                                .font(DesignSystem.Typography.caption.weight(.semibold))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    
                    // Calendar days
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(calendarDays, id: \.self) { date in
                            CalendarDayView(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                hasEvents: hasEventsOnDate(date),
                                isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                            ) {
                                withAnimation(.spring()) {
                                    selectedDate = date
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                }
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                        .fill(.ultraThinMaterial)
                        .glassCard()
                )
                .padding(.horizontal, DesignSystem.Spacing.lg)
                
                // Events for selected date
                if let eventsForDate = eventsForSelectedDate {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        HStack {
                            Text(selectedDate.formatted(date: .complete, time: .omitted))
                                .font(DesignSystem.Typography.title3.weight(.semibold))
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Spacer()
                            
                            Text("\(eventsForDate.count) events")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        ForEach(eventsForDate.prefix(3)) { event in
                            CalendarEventRow(event: event)
                        }
                        
                        if eventsForDate.count > 3 {
                            Button("View all \(eventsForDate.count) events") {
                                // Navigate to events list filtered by date
                            }
                            .font(DesignSystem.Typography.footnote.weight(.semibold))
                            .foregroundColor(DesignSystem.Colors.blue)
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .fill(.ultraThinMaterial)
                            .glassCard()
                    )
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                }
                
                Spacer()
            }
            .padding(.top, DesignSystem.Spacing.lg)
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.spring().delay(0.3)) {
                animateCalendar = true
            }
        }
    }
    
    private var calendarDays: [Date] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        
        var days: [Date] = []
        for i in 0..<42 { // 6 weeks * 7 days
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                days.append(date)
            }
        }
        return days
    }
    
    private func hasEventsOnDate(_ date: Date) -> Bool {
        return eventsService.events.contains { event in
            calendar.isDate(event.start, inSameDayAs: date)
        }
    }
    
    private var eventsForSelectedDate: [CampusEvent]? {
        let events = eventsService.events.filter { event in
            calendar.isDate(event.start, inSameDayAs: selectedDate)
        }
        return events.isEmpty ? nil : events.sorted { $0.start < $1.start }
    }
}

struct CalendarHeader: View {
    @Binding var currentMonth: Date
    
    var body: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                .font(DesignSystem.Typography.title2.weight(.bold))
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private func previousMonth() {
        withAnimation(.spring()) {
            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.spring()) {
            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let hasEvents: Bool
    let isCurrentMonth: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(isSelected ? DesignSystem.Colors.blue : Color.clear)
                    .frame(width: 36, height: 36)
                
                VStack(spacing: 2) {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(DesignSystem.Typography.footnote.weight(.medium))
                        .foregroundColor(
                            isSelected ? .white :
                            isCurrentMonth ? DesignSystem.Colors.textPrimary :
                            DesignSystem.Colors.textTertiary
                        )
                    
                    if hasEvents {
                        Circle()
                            .fill(isSelected ? .white : DesignSystem.Colors.orange)
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CalendarEventRow: View {
    let event: CampusEvent
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Time
            VStack(alignment: .leading, spacing: 2) {
                Text(event.formattedStartTime)
                    .font(DesignSystem.Typography.caption.weight(.semibold))
                    .foregroundColor(DesignSystem.Colors.blue)
                
                Text(formatDuration(event.start, event.end))
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .frame(width: 50, alignment: .leading)
            
            // Event details
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(DesignSystem.Typography.footnote.weight(.medium))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(1)
                
                if !event.location.isEmpty {
                    Text(event.location)
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
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
