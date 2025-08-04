import SwiftUI
import MapKit

struct CampusMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.837732, longitude: -77.238268),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var selectedLocation: CampusLocation?
    @State private var animateContent = false
    
    let campusLocations = [
        CampusLocation(
            name: "Servo Dining Hall",
            description: "Main dining facility",
            coordinate: CLLocationCoordinate2D(latitude: 39.837732, longitude: -77.238268),
            type: .dining,
            hours: "7:00 AM - 9:00 PM"
        ),
        CampusLocation(
            name: "Library",
            description: "Academic library and study spaces",
            coordinate: CLLocationCoordinate2D(latitude: 39.838500, longitude: -77.237500),
            type: .academic,
            hours: "24/7 during finals"
        ),
        CampusLocation(
            name: "Student Center",
            description: "Student activities and services",
            coordinate: CLLocationCoordinate2D(latitude: 39.836800, longitude: -77.239000),
            type: .student,
            hours: "8:00 AM - 11:00 PM"
        ),
        CampusLocation(
            name: "Athletic Center",
            description: "Gym and fitness facilities",
            coordinate: CLLocationCoordinate2D(latitude: 39.839200, longitude: -77.236800),
            type: .athletic,
            hours: "6:00 AM - 11:00 PM"
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Section
                    HeaderSection()
                    
                    // Map View
                    MapViewSection(
                        region: $region,
                        locations: campusLocations,
                        selectedLocation: $selectedLocation
                    )
                    
                    // Location List
                    LocationListSection(
                        locations: campusLocations,
                        selectedLocation: $selectedLocation
                    )
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
struct HeaderSection: View {
    @State private var animateHeader = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Campus")
                        .font(DesignSystem.Typography.title1)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    GradientText("Map", font: DesignSystem.Typography.title1)
                }
                
                Spacer()
                
                // Location button
                Button(action: {
                    // Center on user location
                }) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 20, weight: .medium))
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
            
            Text("Find your way around campus with interactive locations")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.leading)
                .opacity(animateHeader ? 1 : 0)
                .offset(y: animateHeader ? 0 : 20)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.lg)
        .onAppear {
            withAnimation(DesignSystem.Animations.spring.delay(0.3)) {
                animateHeader = true
            }
        }
    }
}

// MARK: - Map View Section
struct MapViewSection: View {
    @Binding var region: MKCoordinateRegion
    let locations: [CampusLocation]
    @Binding var selectedLocation: CampusLocation?
    @State private var animateMap = false
    
    var body: some View {
        ZStack {
            // Map
            Map(coordinateRegion: $region, annotationItems: locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    MapPin(
                        location: location,
                        isSelected: selectedLocation?.id == location.id
                    ) {
                        withAnimation(DesignSystem.Animations.spring) {
                            selectedLocation = location
                        }
                    }
                }
            }
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .opacity(animateMap ? 1 : 0)
            .scaleEffect(animateMap ? 1.0 : 0.95)
            
            // Map controls overlay
            VStack {
                HStack {
                    Spacer()
                    
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        MapControlButton(icon: "plus", action: {
                            // Zoom in
                        })
                        
                        MapControlButton(icon: "minus", action: {
                            // Zoom out
                        })
                    }
                    .padding(.trailing, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.lg)
                }
                
                Spacer()
            }
        }
        .frame(height: 300)
        .onAppear {
            withAnimation(DesignSystem.Animations.spring.delay(0.4)) {
                animateMap = true
            }
        }
    }
}

// MARK: - Map Pin
struct MapPin: View {
    let location: CampusLocation
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Pin
                Image(systemName: location.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(
                                isSelected ?
                                LinearGradient(
                                    colors: [DesignSystem.Colors.orange, DesignSystem.Colors.blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                location.type.color
                            )
                    )
                    .shadow(
                        color: isSelected ? DesignSystem.Shadows.accent.color : DesignSystem.Shadows.medium.color,
                        radius: isSelected ? DesignSystem.Shadows.accent.radius : DesignSystem.Shadows.medium.radius,
                        x: isSelected ? DesignSystem.Shadows.accent.x : DesignSystem.Shadows.medium.x,
                        y: isSelected ? DesignSystem.Shadows.accent.y : DesignSystem.Shadows.medium.y
                    )
                    .scaleEffect(isPressed ? 0.9 : (isSelected ? 1.2 : 1.0))
                
                // Pointer
                Triangle()
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [DesignSystem.Colors.orange, DesignSystem.Colors.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        location.type.color
                    )
                    .frame(width: 12, height: 8)
                    .offset(y: -2)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(DesignSystem.Animations.easeInOut) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Map Control Button
struct MapControlButton: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(DesignSystem.Colors.cardBackground)
                        .shadow(
                            color: DesignSystem.Shadows.medium.color,
                            radius: DesignSystem.Shadows.medium.radius,
                            x: DesignSystem.Shadows.medium.x,
                            y: DesignSystem.Shadows.medium.y
                        )
                )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(DesignSystem.Animations.easeInOut) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Location List Section
struct LocationListSection: View {
    let locations: [CampusLocation]
    @Binding var selectedLocation: CampusLocation?
    @State private var animateList = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Campus Locations")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.lg)
            
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(Array(locations.enumerated()), id: \.element.id) { index, location in
                        LocationCard(
                            location: location,
                            isSelected: selectedLocation?.id == location.id
                        ) {
                            withAnimation(DesignSystem.Animations.spring) {
                                selectedLocation = location
                            }
                        }
                        .opacity(animateList ? 1 : 0)
                        .offset(y: animateList ? 0 : 20)
                        .animation(DesignSystem.Animations.spring.delay(Double(index) * 0.1), value: animateList)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            withAnimation(DesignSystem.Animations.spring.delay(0.5)) {
                animateList = true
            }
        }
    }
}

// MARK: - Location Card
struct LocationCard: View {
    let location: CampusLocation
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Icon
                Image(systemName: location.type.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(location.type.color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(location.type.color.opacity(0.1))
                    )
                
                // Details
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(location.name)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(location.description)
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text(location.hours)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.success)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .glassCard()
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(
                        isSelected ? DesignSystem.Colors.success : Color.clear,
                        lineWidth: 2
                    )
            )
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

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Data Models
struct CampusLocation: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let type: LocationType
    let hours: String
}

enum LocationType: CaseIterable {
    case dining, academic, student, athletic
    
    var icon: String {
        switch self {
        case .dining: return "fork.knife"
        case .academic: return "book.fill"
        case .student: return "person.3.fill"
        case .athletic: return "figure.run"
        }
    }
    
    var color: Color {
        switch self {
        case .dining: return DesignSystem.Colors.orange
        case .academic: return DesignSystem.Colors.blue
        case .student: return DesignSystem.Colors.success
        case .athletic: return DesignSystem.Colors.warning
        }
    }
}
