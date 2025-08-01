import SwiftUI

struct PhoneVerificationView: View {
    @Environment(\.dismiss) private var dismiss
    let phoneNumber: String
    let userData: UserData
    
    @State private var verificationCode = ""
    @State private var showingEmailVerification = false
    @State private var isResending = false
    @State private var timeRemaining = 30
    @State private var canResend = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Verify Your Phone")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("We sent a verification code to")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(phoneNumber)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .padding(.top, 40)
                
                // Verification Code Input
                VStack(spacing: 16) {
                    Text("Enter the 6-digit code")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { index in
                            VerificationCodeDigit(
                                digit: index < verificationCode.count ? String(verificationCode[verificationCode.index(verificationCode.startIndex, offsetBy: index)]) : "",
                                isActive: index == verificationCode.count
                            )
                        }
                    }
                    
                    TextField("", text: $verificationCode)
                        .keyboardType(.numberPad)
                        .opacity(0)
                        .onChange(of: verificationCode) { newValue in
                            // Limit to 6 digits
                            if newValue.count > 6 {
                                verificationCode = String(newValue.prefix(6))
                            }
                            
                            // Auto-submit when 6 digits are entered
                            if newValue.count == 6 {
                                verifyCode()
                            }
                        }
                }
                
                // Resend Code
                VStack(spacing: 8) {
                    if canResend {
                        Button(action: resendCode) {
                            Text("Resend Code")
                                .foregroundColor(.blue)
                        }
                        .disabled(isResending)
                    } else {
                        Text("Resend code in \(timeRemaining)s")
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Continue Button
                Button(action: verifyCode) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(verificationCode.count == 6 ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(verificationCode.count != 6)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingEmailVerification) {
                EmailVerificationView(userData: userData)
            }
            .onAppear {
                startTimer()
            }
        }
    }
    
    private func verifyCode() {
        // Simulate verification
        // In a real app, you would send this to your backend
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            showingEmailVerification = true
        }
    }
    
    private func resendCode() {
        isResending = true
        // Simulate resending code
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isResending = false
            startTimer()
        }
    }
    
    private func startTimer() {
        timeRemaining = 30
        canResend = false
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                canResend = true
                timer.invalidate()
            }
        }
    }
}

struct VerificationCodeDigit: View {
    let digit: String
    let isActive: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(isActive ? Color.blue.opacity(0.1) : Color(.systemGray6))
                .frame(width: 50, height: 60)
            
            if digit.isEmpty {
                if isActive {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 2, height: 20)
                        .opacity(0.8)
                }
            } else {
                Text(digit)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
} 