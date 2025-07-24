import SwiftUI

struct AppButton: View {
    var label: String
    
    var body: some View {
        Text(label)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.themeOrange)
            .cornerRadius(14)
            .shadow(color: Color.themeOrange.opacity(0.15), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
    }
}
