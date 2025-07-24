import SwiftUI

struct QuickIcon: View {
    var name: String
    var systemIcon: String

    var body: some View {
        VStack {
            Circle()
                .fill(Color.themeBlue)
                .frame(width: 50, height: 50)
                .shadow(color: Color.themeSeparator.opacity(0.10), radius: 4, x: 0, y: 2)
                .overlay(
                    Image(systemName: systemIcon)
                        .foregroundColor(.white)
                )
            Text(name)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 80)
                .multilineTextAlignment(.center)
        }
    }
}
