import SwiftUI

struct EventsView: View {
    @StateObject private var eventsService = EventsService.shared
    @State private var selectedEvent: CampusEvent?
    @State private var showingEventDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                if eventsService.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading events...")
                            .bodyText()
                    }
                } else if eventsService.events.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(Color.textSecondary)
                        
                        Text("No Events Available")
                            .sectionHeader()
                        
                        if let error = eventsService.errorMessage {
                            Text("Error: \(error)")
                                .bodyText()
                                .foregroundColor(.red)
                        } else {
                            Text("Check back later for upcoming campus events")
                                .bodyText()
                        }
                        
                        Button("Refresh") {
                            eventsService.refreshEvents()
                        }
                        .modernButton(.primary)
                    }
                    .padding(.horizontal, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(eventsService.events) { event in
                                SimpleEventCard(event: event) {
                                    selectedEvent = event
                                    showingEventDetail = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        eventsService.refreshEvents()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color.primaryAccent)
                    }
                    .disabled(eventsService.isLoading)
                }
            }
            .refreshable {
                eventsService.refreshEvents()
            }
        }
        .sheet(isPresented: $showingEventDetail) {
            if let event = selectedEvent {
                SimpleEventDetailView(event: event)
            }
        }
    }
}

// MARK: - Simple Event Card
struct SimpleEventCard: View {
    let event: CampusEvent
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                Text(event.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.textPrimary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                            .foregroundColor(Color.primaryAccent)
                        
                        Text(event.formattedDateTime)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.primaryAccent)
                    }
                    
                    Spacer()
                }
                
                if !event.location.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.textSecondary)
                        
                        Text(event.location)
                            .font(.system(size: 14))
                            .foregroundColor(Color.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.subtleBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Simple Event Detail View
struct SimpleEventDetailView: View {
    let event: CampusEvent
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
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
                    }
                    
                    if !event.location.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Location", systemImage: "location.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.textPrimary)
                            
                            Text(event.location)
                                .font(.system(size: 16))
                                .foregroundColor(Color.textSecondary)
                        }
                    }
                    
                    if !event.description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Description", systemImage: "text.alignleft")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.textPrimary)
                            
                            Text(event.description)
                                .font(.system(size: 16))
                                .foregroundColor(Color.textSecondary)
                                .lineSpacing(4)
                        }
                    }
                    
                    if let url = event.url {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("More Info", systemImage: "link")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.textPrimary)
                            
                            Link("View Event Details", destination: URL(string: url) ?? URL(string: "https://engage.gettysburg.edu")!)
                                .font(.system(size: 16))
                                .foregroundColor(Color.primaryAccent)
                        }
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
}
