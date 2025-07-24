#if canImport(SwiftUI)
// Only define HomeHeaderView and HomeView here to avoid redeclaration
import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text(getGreeting())
                .font(.largeTitle)
                .bold()
            Text(Date(), formatter: dateFormatter)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
}

#endif
