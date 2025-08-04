import SwiftUI

struct MoreView: View {
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
                        HeaderSection()
                        
                        // Quick Actions
                        QuickActionsSection()
                        
                        // Settings & Support
                        SettingsSupportSection()
                        
                        // About & Legal
                        AboutLegalSection()
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
struct HeaderSection: View {
    @State private var animateHeader = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("More")
                        .font(DesignSystem.Typography.title1)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("Settings, support, and more")
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
}

// MARK: - Quick Actions Section
struct QuickActionsSection: View {
    @State private var animateActions = false
    
    let quickActions = [
        QuickActionItem(
            icon: "bell.fill",
            title: "Notifications",
            subtitle: "Manage your alerts",
            color: DesignSystem.Colors.orange,
            action: { /* Handle notifications */ }
        ),
        QuickActionItem(
            icon: "star.fill",
            title: "Favorites",
            subtitle: "Your saved items",
            color: DesignSystem.Colors.warning,
            action: { /* Handle favorites */ }
        ),
        QuickActionItem(
            icon: "clock.fill",
            title: "Recent",
            subtitle: "Recently viewed",
            color: DesignSystem.Colors.success,
            action: { /* Handle recent */ }
        ),
        QuickActionItem(
            icon: "square.and.arrow.up",
            title: "Share",
            subtitle: "Share the app",
            color: DesignSystem.Colors.blue,
            action: { /* Handle share */ }
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
                    QuickActionCard(action: action)
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
struct QuickActionCard: View {
    let action: QuickActionItem
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action.action) {
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

// MARK: - Settings & Support Section
struct SettingsSupportSection: View {
    @State private var animateSettings = false
    
    let settingsItems = [
        SettingsItem(
            icon: "gear",
            title: "Settings",
            subtitle: "App preferences and configuration",
            type: .settings
        ),
        SettingsItem(
            icon: "questionmark.circle",
            title: "Help & Support",
            subtitle: "Get help and contact support",
            type: .support
        ),
        SettingsItem(
            icon: "envelope",
            title: "Contact Us",
            subtitle: "Send us feedback or questions",
            type: .contact
        ),
        SettingsItem(
            icon: "megaphone",
            title: "Report Issue",
            subtitle: "Report bugs or problems",
            type: .report
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Settings & Support")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            ForEach(Array(settingsItems.enumerated()), id: \.offset) { index, item in
                SettingsCard(item: item)
                    .opacity(animateSettings ? 1 : 0)
                    .offset(y: animateSettings ? 0 : 20)
                    .animation(DesignSystem.Animations.spring.delay(Double(index) * 0.1), value: animateSettings)
            }
        }
        .onAppear {
            withAnimation(DesignSystem.Animations.spring.delay(0.5)) {
                animateSettings = true
            }
        }
    }
}

// MARK: - Settings Card
struct SettingsCard: View {
    let item: SettingsItem
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Handle settings action
        }) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Icon
                Image(systemName: item.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(DesignSystem.Colors.textTertiary.opacity(0.1))
                    )
                
                // Details
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(item.title)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(item.subtitle)
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
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

// MARK: - About & Legal Section
struct AboutLegalSection: View {
    @State private var animateAbout = false
    
    let aboutItems = [
        AboutItem(
            icon: "info.circle",
            title: "About",
            subtitle: "App version and information",
            type: .about
        ),
        AboutItem(
            icon: "doc.text",
            title: "Privacy Policy",
            subtitle: "How we handle your data",
            type: .privacy
        ),
        AboutItem(
            icon: "doc.plaintext",
            title: "Terms of Service",
            subtitle: "App usage terms",
            type: .terms
        ),
        AboutItem(
            icon: "hand.raised",
            title: "Accessibility",
            subtitle: "Accessibility features",
            type: .accessibility
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("About & Legal")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            ForEach(Array(aboutItems.enumerated()), id: \.offset) { index, item in
                AboutCard(item: item)
                    .opacity(animateAbout ? 1 : 0)
                    .offset(y: animateAbout ? 0 : 20)
                    .animation(DesignSystem.Animations.spring.delay(Double(index) * 0.1), value: animateAbout)
            }
        }
        .onAppear {
            withAnimation(DesignSystem.Animations.spring.delay(0.6)) {
                animateAbout = true
            }
        }
    }
}

// MARK: - About Card
struct AboutCard: View {
    let item: AboutItem
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Handle about action
        }) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Icon
                Image(systemName: item.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(DesignSystem.Colors.textTertiary.opacity(0.1))
                    )
                
                // Details
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(item.title)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(item.subtitle)
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
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

// MARK: - Data Models
struct QuickActionItem {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
}

struct SettingsItem {
    let icon: String
    let title: String
    let subtitle: String
    let type: SettingsType
}

enum SettingsType {
    case settings, support, contact, report
}

struct AboutItem {
    let icon: String
    let title: String
    let subtitle: String
    let type: AboutType
}

enum AboutType {
    case about, privacy, terms, accessibility
}
