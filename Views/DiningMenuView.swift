import SwiftUI

struct DiningMenuView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Dining")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color.textPrimary)
                        
                        Text("Check hours, menus, and availability")
                            .bodyText()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Dining Locations
                    VStack(spacing: 16) {
                        HStack {
                            Text("Dining Locations")
                                .sectionHeader()
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            DiningLocationCard(
                                name: "Servo",
                                status: "Open",
                                hours: "7:00 AM - 9:00 PM",
                                crowd: "Medium",
                                color: Color(hex: "10B981")
                            )
                            
                            DiningLocationCard(
                                name: "Bullet Hole",
                                status: "Open",
                                hours: "8:00 AM - 11:00 PM",
                                crowd: "Busy",
                                color: Color(hex: "F59E0B")
                            )
                            
                            DiningLocationCard(
                                name: "The Dive",
                                status: "Closed",
                                hours: "11:00 AM - 8:00 PM",
                                crowd: "Closed",
                                color: Color(hex: "EF4444")
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Today's Specials
                    VStack(spacing: 16) {
                        HStack {
                            Text("Today's Specials")
                                .sectionHeader()
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            MenuItemCard(
                                name: "Grilled Chicken Caesar Salad",
                                location: "Servo",
                                price: "$8.50",
                                description: "Fresh romaine, parmesan, croutons with caesar dressing"
                            )
                            
                            MenuItemCard(
                                name: "Build Your Own Pizza",
                                location: "Bullet Hole",
                                price: "$10.00",
                                description: "Choose your toppings and watch it cook in our stone oven"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Meal Plan Info
                    VStack(spacing: 16) {
                        HStack {
                            Text("Meal Plan")
                                .sectionHeader()
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            MealPlanCard(
                                title: "Weekly Balance",
                                value: "12 meals remaining",
                                icon: "fork.knife"
                            )
                            
                            MealPlanCard(
                                title: "Flex Dollars",
                                value: "$45.20 remaining",
                                icon: "dollarsign.circle"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.background)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DiningLocationCard: View {
    let name: String
    let status: String
    let hours: String
    let crowd: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.textPrimary)
                    
                    Spacer()
                    
                    Text(status)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Text(hours)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.textSecondary)
                
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color.textSecondary)
                    
                    Text(crowd)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.textSecondary)
                }
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

struct MenuItemCard: View {
    let name: String
    let location: String
    let price: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.textPrimary)
                    
                    Text(location)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.primaryAccent)
                }
                
                Spacer()
                
                Text(price)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.textPrimary)
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

struct MealPlanCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color.primaryAccent)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.textSecondary)
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.textPrimary)
            }
            
            Spacer()
        }
        .padding(16)
        .modernCard()
    }
}
