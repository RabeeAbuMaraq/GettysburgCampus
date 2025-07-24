import SwiftUI

struct EventRow: View {
    var date: String
    var title: String
    var time: String
    var location: String

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 2) {
                Text(String(date.prefix(2)))
                    .font(.title2)
                    .bold()
                    .foregroundColor(.themeOrange)
                Text(String(date.suffix(3)))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(width: 50)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.themeText)
                    .fontWeight(.medium)
                Text("\(time) · \(location)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.themeCard)
        .cornerRadius(14)
        .shadow(color: Color.themeSeparator.opacity(0.15), radius: 6, x: 0, y: 2)
    }
}
