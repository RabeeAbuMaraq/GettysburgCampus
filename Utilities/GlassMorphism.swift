import SwiftUI

// MARK: - Color Palette
extension Color {
    static let primaryAccent = Color(hex: "0D6EFD")      // Apple-style blue
    static let background = Color(hex: "F8FAFC")         // Soft white/gray
    static let textPrimary = Color(hex: "0F172A")        // Deep slate
    static let textSecondary = Color(hex: "64748B")      // Muted slate
    static let callToAction = Color(hex: "1E293B")       // Dark slate
    static let cardBackground = Color.white
    static let subtleBorder = Color(hex: "E2E8F0")       // Light border
}

// MARK: - Design System
struct ModernCard: ViewModifier {
    let hasShadow: Bool
    
    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.subtleBorder, lineWidth: 1)
            )
            .shadow(
                color: hasShadow ? Color.black.opacity(0.05) : Color.clear,
                radius: 8,
                x: 0,
                y: 2
            )
    }
}

struct ModernButton: ViewModifier {
    let style: ButtonStyle
    let isEnabled: Bool
    
    enum ButtonStyle {
        case primary, secondary, subtle
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
            .shadow(
                color: shadowColor,
                radius: 4,
                x: 0,
                y: 2
            )
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return isEnabled ? Color.primaryAccent : Color.textSecondary.opacity(0.3)
        case .secondary:
            return Color.cardBackground
        case .subtle:
            return Color.background
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary, .subtle:
            return Color.textPrimary
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary:
            return Color.clear
        case .secondary:
            return Color.subtleBorder
        case .subtle:
            return Color.clear
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return isEnabled ? Color.primaryAccent.opacity(0.3) : Color.clear
        case .secondary, .subtle:
            return Color.black.opacity(0.05)
        }
    }
}

struct ModernTextField: ViewModifier {
    @FocusState var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.primaryAccent : Color.subtleBorder, lineWidth: isFocused ? 2 : 1)
            )
            .shadow(
                color: isFocused ? Color.primaryAccent.opacity(0.1) : Color.black.opacity(0.02),
                radius: 4,
                x: 0,
                y: 1
            )
    }
}

struct SectionHeader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(Color.textPrimary)
    }
}

struct BodyText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(Color.textSecondary)
            .lineSpacing(4)
    }
}

struct CaptionText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color.textSecondary)
    }
}

// MARK: - View Extensions
extension View {
    func modernCard(hasShadow: Bool = true) -> some View {
        modifier(ModernCard(hasShadow: hasShadow))
    }
    
    func modernButton(_ style: ModernButton.ButtonStyle = .primary, isEnabled: Bool = true) -> some View {
        modifier(ModernButton(style: style, isEnabled: isEnabled))
    }
    
    func modernTextField() -> some View {
        modifier(ModernTextField())
    }
    
    func sectionHeader() -> some View {
        modifier(SectionHeader())
    }
    
    func bodyText() -> some View {
        modifier(BodyText())
    }
    
    func captionText() -> some View {
        modifier(CaptionText())
    }
} 