import SwiftUI

struct DiningMenuView: View {
    @State private var selectedMeal: MealType = .lunch
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
                        DiningHeaderSection()
                        
                        // Meal Type Selector
                        MealTypeSelector(selectedMeal: $selectedMeal)
                        
                        // Dining Locations
                        DiningLocationsSection()
                        
                        // Today's Menu
                        TodaysMenuSection(mealType: selectedMeal)
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
struct DiningHeaderSection: View {
    @State private var animateHeader = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Campus")
                        .font(DesignSystem.Typography.title1)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    GradientText("Dining", font: DesignSystem.Typography.title1)
                }
                
                Spacer()
                
                // Refresh button
                Button(action: {
                    // Refresh dining data
                }) {
                    Image(systemName: "arrow.clockwise")
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
            
            Text("Discover delicious meals and dining options across campus")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.leading)
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
}

// MARK: - Meal Type Selector
struct MealTypeSelector: View {
    @Binding var selectedMeal: MealType
    @State private var animateSelector = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Meal Type")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(MealType.allCases, id: \.self) { meal in
                    MealTypeButton(
                        meal: meal,
                        isSelected: selectedMeal == meal,
                        onTap: {
                            withAnimation(DesignSystem.Animations.spring) {
                                selectedMeal = meal
                            }
                        }
                    )
                    .opacity(animateSelector ? 1 : 0)
                    .offset(y: animateSelector ? 0 : 20)
                    .animation(DesignSystem.Animations.spring.delay(Double(MealType.allCases.firstIndex(of: meal) ?? 0) * 0.1), value: animateSelector)
                }
            }
        }
        .onAppear {
            withAnimation(DesignSystem.Animations.spring.delay(0.4)) {
                animateSelector = true
            }
        }
    }
}

// MARK: - Meal Type Button
struct MealTypeButton: View {
    let meal: MealType
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: meal.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.textSecondary)
                
                Text(meal.title)
                    .font(DesignSystem.Typography.footnote.weight(.semibold))
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [DesignSystem.Colors.orange, DesignSystem.Colors.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        DesignSystem.Colors.cardBackground
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(
                        isSelected ? Color.clear : DesignSystem.Colors.textTertiary,
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? DesignSystem.Shadows.accent.color : DesignSystem.Shadows.small.color,
                radius: isSelected ? DesignSystem.Shadows.accent.radius : DesignSystem.Shadows.small.radius,
                x: isSelected ? DesignSystem.Shadows.accent.x : DesignSystem.Shadows.small.x,
                y: isSelected ? DesignSystem.Shadows.accent.y : DesignSystem.Shadows.small.y
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(DesignSystem.Animations.easeInOut) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Dining Locations Section
struct DiningLocationsSection: View {
    @State private var animateLocations = false
    
    let diningLocations = [
        DiningLocation(
            name: "Servo",
            description: "Main dining hall with diverse options",
            hours: "7:00 AM - 9:00 PM",
            status: .open,
            icon: "building.2"
        ),
        DiningLocation(
            name: "Bullet Hole",
            description: "Quick bites and coffee",
            hours: "8:00 AM - 11:00 PM",
            status: .open,
            icon: "cup.and.saucer"
        ),
        DiningLocation(
            name: "The Dive",
            description: "Late night dining options",
            hours: "4:00 PM - 2:00 AM",
            status: .open,
            icon: "clock"
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Dining Locations")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            ForEach(Array(diningLocations.enumerated()), id: \.offset) { index, location in
                DiningLocationCard(location: location)
                    .opacity(animateLocations ? 1 : 0)
                    .offset(y: animateLocations ? 0 : 20)
                    .animation(DesignSystem.Animations.spring.delay(Double(index) * 0.1), value: animateLocations)
            }
        }
        .onAppear {
            withAnimation(DesignSystem.Animations.spring.delay(0.5)) {
                animateLocations = true
            }
        }
    }
}

// MARK: - Dining Location Card
struct DiningLocationCard: View {
    let location: DiningLocation
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Navigate to location detail
        }) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Icon
                Image(systemName: location.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(location.status == .open ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(location.status == .open ? DesignSystem.Colors.success.opacity(0.1) : DesignSystem.Colors.error.opacity(0.1))
                    )
                
                // Details
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack {
                        Text(location.name)
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Spacer()
                        
                        // Status indicator
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Circle()
                                .fill(location.status == .open ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                                .frame(width: 8, height: 8)
                            
                            Text(location.status == .open ? "Open" : "Closed")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(location.status == .open ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                        }
                    }
                    
                    Text(location.description)
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text(location.hours)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
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
}

// MARK: - Today's Menu Section
struct TodaysMenuSection: View {
    let mealType: MealType
    @State private var animateMenu = false
    
    var menuItems: [MenuItem] {
        switch mealType {
        case .breakfast:
            return [
                MenuItem(name: "Scrambled Eggs", description: "Fresh eggs with herbs", category: .main),
                MenuItem(name: "Belgian Waffles", description: "Served with maple syrup", category: .main),
                MenuItem(name: "Fresh Fruit", description: "Seasonal selection", category: .side),
                MenuItem(name: "Orange Juice", description: "Freshly squeezed", category: .beverage)
            ]
        case .lunch:
            return [
                MenuItem(name: "Grilled Chicken Sandwich", description: "With lettuce and tomato", category: .main),
                MenuItem(name: "Caesar Salad", description: "Fresh greens with dressing", category: .side),
                MenuItem(name: "French Fries", description: "Crispy golden fries", category: .side),
                MenuItem(name: "Iced Tea", description: "Refreshing beverage", category: .beverage)
            ]
        case .dinner:
            return [
                MenuItem(name: "Grilled Salmon", description: "With lemon butter sauce", category: .main),
                MenuItem(name: "Mashed Potatoes", description: "Creamy and smooth", category: .side),
                MenuItem(name: "Steamed Vegetables", description: "Fresh seasonal veggies", category: .side),
                MenuItem(name: "Chocolate Cake", description: "Rich and decadent", category: .dessert)
            ]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Today's \(mealType.title) Menu")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.md) {
                ForEach(Array(menuItems.enumerated()), id: \.offset) { index, item in
                    MenuItemCard(item: item)
                        .opacity(animateMenu ? 1 : 0)
                        .offset(y: animateMenu ? 0 : 20)
                        .animation(DesignSystem.Animations.spring.delay(Double(index) * 0.1), value: animateMenu)
                }
            }
        }
        .onAppear {
            withAnimation(DesignSystem.Animations.spring.delay(0.6)) {
                animateMenu = true
            }
        }
        .onChange(of: mealType) { _ in
            animateMenu = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(DesignSystem.Animations.spring) {
                    animateMenu = true
                }
            }
        }
    }
}

// MARK: - Menu Item Card
struct MenuItemCard: View {
    let item: MenuItem
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Show item details
        }) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                // Category badge
                HStack {
                    Text(item.category.rawValue.uppercased())
                        .font(DesignSystem.Typography.caption.weight(.semibold))
                        .foregroundColor(categoryColor)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(categoryColor.opacity(0.1))
                        )
                    
                    Spacer()
                }
                
                // Item details
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(item.name)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .lineLimit(2)
                    
                    Text(item.description)
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(2)
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
    
    private var categoryColor: Color {
        switch item.category {
        case .main: return DesignSystem.Colors.orange
        case .side: return DesignSystem.Colors.success
        case .dessert: return DesignSystem.Colors.warning
        case .beverage: return DesignSystem.Colors.blue
        }
    }
}

// MARK: - Data Models
enum MealType: CaseIterable {
    case breakfast, lunch, dinner
    
    var title: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        }
    }
    
    var icon: String {
        switch self {
        case .breakfast: return "sunrise"
        case .lunch: return "sun.max"
        case .dinner: return "moon"
        }
    }
}

struct DiningLocation {
    let name: String
    let description: String
    let hours: String
    let status: LocationStatus
    let icon: String
}

enum LocationStatus {
    case open, closed
}

struct MenuItem {
    let name: String
    let description: String
    let category: MenuCategory
}

enum MenuCategory: String, CaseIterable {
    case main = "Main"
    case side = "Side"
    case dessert = "Dessert"
    case beverage = "Beverage"
}
