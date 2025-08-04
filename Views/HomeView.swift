#if canImport(SwiftUI)
// Only define HomeHeaderView and HomeView here to avoid redeclaration
import SwiftUI

struct HomeView: View {
    @StateObject private var eventsService = EventsService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Good morning")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color.textPrimary)
                        
                        Text("Here's what's happening on campus today")
                            .bodyText()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Quick Actions
                    VStack(spacing: 16) {
                        HStack {
                            Text("Quick Actions")
                                .sectionHeader()
                            Spacer()
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            QuickActionCard(
                                icon: "fork.knife",
                                title: "Dining",
                                subtitle: "Check hours & menus",
                                color: Color.primaryAccent
                            )
                            
                            QuickActionCard(
                                icon: "calendar",
                                title: "Events",
                                subtitle: "\(eventsService.events.count) events",
                                color: Color.accentGreen
                            )
                            
                            QuickActionCard(
                                icon: "map.fill",
                                title: "Campus Map",
                                subtitle: "Find your way around",
                                color: Color.accentYellow
                            )
                            
                            QuickActionCard(
                                icon: "bus.fill",
                                title: "Shuttle",
                                subtitle: "Next: 4:25 PM",
                                color: Color.accentPurple
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Today's Schedule
                    VStack(spacing: 16) {
                        HStack {
                            Text("Today's Schedule")
                                .sectionHeader()
                            Spacer()
                            Button("View All") {
                                // Navigate to full schedule
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.primaryAccent)
                        }
                        
                        VStack(spacing: 12) {
                            ScheduleCard(
                                time: "9:00 AM",
                                title: "Introduction to Computer Science",
                                location: "Glatfelter Hall 101",
                                duration: "75 min"
                            )
                            
                            ScheduleCard(
                                time: "11:00 AM",
                                title: "Calculus II",
                                location: "Breidenbaugh Hall 201",
                                duration: "75 min"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Campus Updates
                    VStack(spacing: 16) {
                        HStack {
                            Text("Campus Updates")
                                .sectionHeader()
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            UpdateCard(
                                title: "Library Extended Hours",
                                description: "The library will be open until 2 AM during finals week",
                                time: "2 hours ago"
                            )
                            
                            UpdateCard(
                                title: "Weather Alert",
                                description: "Light rain expected this afternoon. Bring an umbrella!",
                                time: "4 hours ago"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Profile or settings
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.primaryAccent)
                    }
                }
            }
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Navigate to respective section
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.textSecondary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .modernCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ScheduleCard: View {
    let time: String
    let title: String
    let location: String
    let duration: String
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(time)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.primaryAccent)
                
                Text(duration)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.textSecondary)
            }
            .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.textPrimary)
                
                Text(location)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.textSecondary)
        }
        .padding(16)
        .modernCard()
    }
}

struct UpdateCard: View {
    let title: String
    let description: String
    let time: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.textPrimary)
                
                Spacer()
                
                Text(time)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.textSecondary)
            }
            
            Text(description)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.textSecondary)
                .lineSpacing(2)
        }
        .padding(16)
        .modernCard()
    }
}

#endif
