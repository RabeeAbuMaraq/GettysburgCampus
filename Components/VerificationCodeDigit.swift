import SwiftUI

struct VerificationCodeDigit: View {
    let digit: String
    let isActive: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.1) : Color.white)
                .frame(width: 50, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? Color(red: 0.1, green: 0.2, blue: 0.4) : Color.gray.opacity(0.3), lineWidth: isActive ? 2 : 1)
                )
            
            if digit.isEmpty {
                if isActive {
                    Rectangle()
                        .fill(Color(red: 0.1, green: 0.2, blue: 0.4))
                        .frame(width: 2, height: 20)
                        .opacity(0.8)
                }
            } else {
                Text(digit)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
            }
        }
    }
} 