import SwiftUI

struct CampusMapView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Campus Map")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color.textPrimary)
                        
                        Text("Find buildings, parking, and navigate campus")
                            .bodyText()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Map Placeholder
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.cardBackground)
                                .frame(height: 300)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.subtleBorder, lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                            
                            VStack(spacing: 12) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 48, weight: .light))
                                    .foregroundColor(Color.primaryAccent)
                                
                                Text("Interactive Campus Map")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.textPrimary)
                                
                                Text("Coming Soon")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Quick Search
                    VStack(spacing: 16) {
                        HStack {
                            Text("Quick Search")
                                .sectionHeader()
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            SearchCard(
                                title: "Academic Buildings",
                                icon: "building.columns.fill",
                                count: "12 buildings",
                                color: Color.primaryAccent
                            )
                            
                            SearchCard(
                                title: "Dining Locations",
                                icon: "fork.knife",
                                count: "3 locations",
                                color: Color(hex: "10B981")
                            )
                            
                            SearchCard(
                                title: "Parking Lots",
                                icon: "car.fill",
                                count: "8 lots",
                                color: Color(hex: "F59E0B")
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Popular Locations
                    VStack(spacing: 16) {
                        HStack {
                            Text("Popular Locations")
                                .sectionHeader()
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            LocationCard(
                                name: "College Union Building",
                                description: "Student center, dining, and meeting spaces",
                                distance: "2 min walk",
                                icon: "building.2.fill"
                            )
                            
                            LocationCard(
                                name: "Library",
                                description: "Study spaces, research resources, and computer labs",
                                distance: "5 min walk",
                                icon: "books.vertical.fill"
                            )
                            
                            LocationCard(
                                name: "Athletic Center",
                                description: "Gym, pool, courts, and fitness facilities",
                                distance: "8 min walk",
                                icon: "sportscourt.fill"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Navigation Tools
                    VStack(spacing: 16) {
                        HStack {
                            Text("Navigation Tools")
                                .sectionHeader()
                            Spacer()
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ToolCard(
                                title: "Directions",
                                icon: "location.fill",
                                description: "Get walking directions"
                            )
                            
                            ToolCard(
                                title: "Parking",
                                icon: "car.fill",
                                description: "Find available parking"
                            )
                            
                            ToolCard(
                                title: "Accessibility",
                                icon: "figure.roll",
                                description: "Accessible routes"
                            )
                            
                            ToolCard(
                                title: "Emergency",
                                icon: "exclamationmark.triangle.fill",
                                description: "Emergency locations"
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
                        // Search or filter
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.primaryAccent)
                    }
                }
            }
        }
    }
}

struct SearchCard: View {
    let title: String
    let icon: String
    let count: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Navigate to search results
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.textPrimary)
                    
                    Text(count)
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
        .buttonStyle(PlainButtonStyle())
    }
}

struct LocationCard: View {
    let name: String
    let description: String
    let distance: String
    let icon: String
    
    var body: some View {
        Button(action: {
            // Show location details
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.primaryAccent)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.textPrimary)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(distance)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.primaryAccent)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.textSecondary)
                }
            }
            .padding(16)
            .modernCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ToolCard: View {
    let title: String
    let icon: String
    let description: String
    
    var body: some View {
        Button(action: {
            // Open tool
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.primaryAccent)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.textPrimary)
                    
                    Text(description)
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
