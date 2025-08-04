import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("More")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color.textPrimary)
                        
                        Text("Settings, support, and additional features")
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
                        
                        VStack(spacing: 12) {
                            ActionCard(
                                title: "Student ID",
                                subtitle: "Digital ID card and access",
                                icon: "creditcard.fill",
                                color: Color.primaryAccent
                            )
                            
                            ActionCard(
                                title: "Laundry",
                                subtitle: "Check machine status",
                                icon: "tshirt.fill",
                                color: Color(hex: "10B981")
                            )
                            
                            ActionCard(
                                title: "Shuttle",
                                subtitle: "Real-time shuttle tracking",
                                icon: "bus.fill",
                                color: Color(hex: "F59E0B")
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Campus Services
                    VStack(spacing: 16) {
                        HStack {
                            Text("Campus Services")
                                .sectionHeader()
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            ServiceCard(
                                title: "Health Center",
                                description: "Medical appointments and health resources",
                                icon: "cross.fill",
                                color: Color(hex: "EF4444")
                            )
                            
                            ServiceCard(
                                title: "IT Support",
                                description: "Technology help and troubleshooting",
                                icon: "laptopcomputer",
                                color: Color(hex: "8B5CF6")
                            )
                            
                            ServiceCard(
                                title: "Library Services",
                                description: "Research help, study rooms, and resources",
                                icon: "books.vertical.fill",
                                color: Color(hex: "06B6D4")
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Settings & Support
                    VStack(spacing: 16) {
                        HStack {
                            Text("Settings & Support")
                                .sectionHeader()
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            SettingCard(
                                title: "Notifications",
                                subtitle: "Manage push notifications",
                                icon: "bell.fill"
                            )
                            
                            SettingCard(
                                title: "Privacy",
                                subtitle: "Privacy settings and data usage",
                                icon: "lock.fill"
                            )
                            
                            SettingCard(
                                title: "Help & Support",
                                subtitle: "Contact support and FAQs",
                                icon: "questionmark.circle.fill"
                            )
                            
                            SettingCard(
                                title: "About",
                                subtitle: "App version and information",
                                icon: "info.circle.fill"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Emergency & Safety
                    VStack(spacing: 16) {
                        HStack {
                            Text("Emergency & Safety")
                                .sectionHeader()
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            EmergencyCard(
                                title: "Campus Safety",
                                description: "Emergency contacts and safety resources",
                                icon: "shield.fill",
                                color: Color(hex: "EF4444")
                            )
                            
                            EmergencyCard(
                                title: "Blue Light Locations",
                                description: "Emergency phone locations on campus",
                                icon: "lightbulb.fill",
                                color: Color(hex: "3B82F6")
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
                        // Settings or profile
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.primaryAccent)
                    }
                }
            }
        }
    }
}

struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Navigate to feature
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
                    
                    Text(subtitle)
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

struct ServiceCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Navigate to service
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                        .frame(width: 24)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.textSecondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.textPrimary)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.textSecondary)
                        .lineLimit(2)
                }
            }
            .padding(16)
            .modernCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingCard: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        Button(action: {
            // Navigate to setting
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.primaryAccent)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.textPrimary)
                    
                    Text(subtitle)
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

struct EmergencyCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Navigate to emergency resource
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                        .frame(width: 24)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.textSecondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.textPrimary)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.textSecondary)
                        .lineLimit(2)
                }
            }
            .padding(16)
            .modernCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
}
