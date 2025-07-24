import SwiftUI

struct ToggleRow: View {
    var title: String
    var icon: String
    @Binding var isOn: Bool
    var subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.themeOrange)
                Toggle(isOn: $isOn) {
                    Text(title)
                        .foregroundColor(.themeText)
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.themeSecondaryText)
                .padding(.leading, 40)
        }
    }
}
