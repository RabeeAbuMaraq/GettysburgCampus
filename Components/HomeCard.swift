import SwiftUI

struct HomeCard: View {
    var color: Color
    var title: String
    var subtitle: String
    var icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.black)
                Spacer()
            }
            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(.black)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 160, height: 100)
        .background(color)
        .cornerRadius(18)
        .shadow(color: Color.themeSeparator.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}
