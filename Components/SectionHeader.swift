import SwiftUI

struct SectionHeader: View {
    var title: String
    var icon: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.themeBlue)
            Text(title)
                .font(.title3).bold()
                .foregroundColor(.themeText)
        }
        .padding(.horizontal)
    }
}

