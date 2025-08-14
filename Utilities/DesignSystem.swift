import SwiftUI

// MARK: - Design System
struct DesignSystem {
    
    // MARK: - Colors (Matching Website)
    struct Colors {
        // Primary Brand Colors
        static let orange = Color(hex: "#CC4E00")
        static let blue = Color(hex: "#043B82")
        static let darkBlue = Color(hex: "#1e40af")
        
        // Background Colors
        static let backgroundGradient = LinearGradient(
            colors: [Color(hex: "#fff7ed"), Color(hex: "#f8fafc")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Text Colors
        static let textPrimary = Color(hex: "#1f2937")
        static let textSecondary = Color(hex: "#6b7280")
        static let textTertiary = Color(hex: "#9ca3af")
        
        // Card Colors
        static let cardBackground = Color.white.opacity(0.8)
        static let cardBorder = Color.white.opacity(0.3)
        
        // Status Colors
        static let success = Color(hex: "#10B981")
        static let warning = Color(hex: "#F59E0B")
        static let error = Color(hex: "#EF4444")
        static let purple = Color(hex: "#8B5CF6")
        static let indigo = Color(hex: "#6366F1")
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 48, weight: .bold, design: .rounded)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 24, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 16, weight: .medium, design: .rounded)
        static let callout = Font.system(size: 16, weight: .medium, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .medium, design: .rounded)
        static let footnote = Font.system(size: 14, weight: .medium, design: .rounded)
        static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
        static let caption2 = Font.system(size: 10, weight: .medium, design: .rounded)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        static let medium = Shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        static let large = Shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
        static let accent = Shadow(color: Colors.orange.opacity(0.3), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Animations
    struct Animations {
        static let spring = Animation.spring(response: 0.6, dampingFraction: 0.8)
        static let springSlow = Animation.spring(response: 0.8, dampingFraction: 0.8)
        static let easeInOut = Animation.easeInOut(duration: 0.3)
        static let linear = Animation.linear(duration: 1.2)
    }
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Gradient Text
struct GradientText: View {
    let text: String
    let font: Font
    
    init(_ text: String, font: Font = DesignSystem.Typography.largeTitle) {
        self.text = text
        self.font = font
    }
    
    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(
                LinearGradient(
                    colors: [DesignSystem.Colors.orange, DesignSystem.Colors.blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

// MARK: - Glass Card
struct GlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = DesignSystem.CornerRadius.lg, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(DesignSystem.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(DesignSystem.Colors.cardBorder, lineWidth: 1)
                    )
            )
            .shadow(
                color: DesignSystem.Shadows.medium.color,
                radius: DesignSystem.Shadows.medium.radius,
                x: DesignSystem.Shadows.medium.x,
                y: DesignSystem.Shadows.medium.y
            )
    }
}

// MARK: - Gradient Button
struct GradientButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isLoading: Bool
    
    init(_ title: String, icon: String? = nil, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(title)
                    .font(DesignSystem.Typography.body.weight(.semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .background(
                LinearGradient(
                    colors: [DesignSystem.Colors.orange, DesignSystem.Colors.blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(
                color: DesignSystem.Shadows.accent.color,
                radius: DesignSystem.Shadows.accent.radius,
                x: DesignSystem.Shadows.accent.x,
                y: DesignSystem.Shadows.accent.y
            )
        }
        .disabled(isLoading)
        .scaleEffect(isLoading ? 0.98 : 1.0)
        .animation(DesignSystem.Animations.spring, value: isLoading)
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(title)
                    .font(DesignSystem.Typography.body.weight(.semibold))
            }
            .foregroundColor(DesignSystem.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.textTertiary, lineWidth: 1)
            )
        }
        .scaleEffect(1.0)
        .animation(DesignSystem.Animations.spring, value: true)
    }
}

// MARK: - Loading Spinner
struct LoadingSpinner: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(DesignSystem.Colors.textTertiary.opacity(0.3), lineWidth: 4)
                .frame(width: 40, height: 40)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    LinearGradient(
                        colors: [DesignSystem.Colors.orange, DesignSystem.Colors.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(-90))
                .animation(DesignSystem.Animations.linear.repeatForever(autoreverses: false), value: true)
        }
    }
}

// MARK: - Empty State
struct EmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(icon: String, title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            Text(title)
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text(message)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xxl)
            
            if let actionTitle = actionTitle, let action = action {
                GradientButton(actionTitle, action: action)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - View Extensions
extension View {
    func glassCard(cornerRadius: CGFloat = DesignSystem.CornerRadius.lg) -> some View {
        self
            .padding(DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(DesignSystem.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(DesignSystem.Colors.cardBorder, lineWidth: 1)
                    )
            )
            .shadow(
                color: DesignSystem.Shadows.medium.color,
                radius: DesignSystem.Shadows.medium.radius,
                x: DesignSystem.Shadows.medium.x,
                y: DesignSystem.Shadows.medium.y
            )
    }
    
    func animateIn(delay: Double = 0) -> some View {
        self
            .opacity(0)
            .offset(y: 20)
            .onAppear {
                withAnimation(DesignSystem.Animations.spring.delay(delay)) {
                    // This will be handled by the parent view
                }
            }
    }
} 