import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        
        self.init(red: r, green: g, blue: b)
    }

    // Updated color scheme to match website aesthetic
    static let themeOrange = Color(hex: "#FF7A00")
    static let themeBlue = Color(hex: "#0056B3")
    static let themeBackground = Color(hex: "#FAFAFA")
    static let themeCard = Color.white
    static let themeSeparator = Color(hex: "#E5E5E5")
    static let themeText = Color(hex: "#222222")
    static let themeSecondaryText = Color(hex: "#666666")
    
    // Additional colors for better design
    static let accentGreen = Color(hex: "#10B981")
    static let accentYellow = Color(hex: "#F59E0B")
    static let accentPurple = Color(hex: "#8B5CF6")
    static let accentRed = Color(hex: "#EF4444")
    static let accentPink = Color(hex: "#EC4899")
}
