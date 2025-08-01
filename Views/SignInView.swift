import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    @State private var campusEmail = ""
    @State private var showingEmailVerification = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.98, green: 0.98, blue: 1.0)
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 20) {
                        // Clock Tower Icon
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                        }
                        .padding(.top, 40)
                        
                        VStack(spacing: 12) {
                            Text("Welcome Back")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                            
                            Text("Sign in to your Gettysburg account")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Email Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Campus Email")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                        
                        TextField("username@gettysburg.edu", text: $campusEmail)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Continue Button
                    Button(action: {
                        if isValidEmail() {
                            initiateSignIn()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            Text(isLoading ? "Sending Code..." : "Continue")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: isValidEmail() && !isLoading ? [
                                    Color(red: 0.2, green: 0.6, blue: 1.0),
                                    Color(red: 0.1, green: 0.4, blue: 0.8)
                                ] : [
                                    Color.gray.opacity(0.5),
                                    Color.gray.opacity(0.3)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: isValidEmail() && !isLoading ? Color.black.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
                    }
                    .disabled(!isValidEmail() || isLoading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                }
            }
            .sheet(isPresented: $showingEmailVerification) {
                SignInEmailVerificationView(campusEmail: campusEmail)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func isValidEmail() -> Bool {
        !campusEmail.isEmpty && campusEmail.contains("@gettysburg.edu")
    }
    
    private func initiateSignIn() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let response = try await authService.signIn(email: campusEmail)
                
                await MainActor.run {
                    isLoading = false
                    
                    if response.success {
                        showingEmailVerification = true
                    } else {
                        errorMessage = response.message
                        showingError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}

struct SignInEmailVerificationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    let campusEmail: String
    
    @State private var verificationCode = ""
    @State private var showingMainApp = false
    @State private var isResending = false
    @State private var timeRemaining = 30
    @State private var canResend = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @FocusState private var isCodeFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.98, green: 0.98, blue: 1.0)
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 20) {
                        // Clock Tower Icon
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "envelope.circle.fill")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                        }
                        .padding(.top, 40)
                        
                        VStack(spacing: 12) {
                            Text("Verify Your Email")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                            
                            Text("We sent a verification code to")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Text(campusEmail)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Verification Code Input
                    VStack(spacing: 20) {
                        Text("Enter the 6-digit code")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                        
                        // Code Input Field
                        HStack(spacing: 12) {
                            ForEach(0..<6, id: \.self) { index in
                                VerificationCodeDigit(
                                    digit: index < verificationCode.count ? String(verificationCode[verificationCode.index(verificationCode.startIndex, offsetBy: index)]) : "",
                                    isActive: index == verificationCode.count && isCodeFieldFocused
                                )
                            }
                        }
                        
                        // Hidden TextField for input
                        TextField("", text: $verificationCode)
                            .keyboardType(.numberPad)
                            .focused($isCodeFieldFocused)
                            .opacity(0)
                            .onChange(of: verificationCode) { newValue in
                                // Limit to 6 digits
                                if newValue.count > 6 {
                                    verificationCode = String(newValue.prefix(6))
                                }
                                
                                // Auto-submit when 6 digits are entered
                                if newValue.count == 6 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        verifyCode()
                                    }
                                }
                            }
                    }
                    
                    // Resend Code
                    VStack(spacing: 8) {
                        if canResend {
                            Button(action: resendCode) {
                                Text("Resend Code")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                            }
                            .disabled(isResending)
                        } else {
                            Text("Resend code in \(timeRemaining)s")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // Continue Button
                    Button(action: verifyCode) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            Text(isLoading ? "Verifying..." : "Sign In")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: verificationCode.count == 6 && !isLoading ? [
                                    Color(red: 0.2, green: 0.6, blue: 1.0),
                                    Color(red: 0.1, green: 0.4, blue: 0.8)
                                ] : [
                                    Color.gray.opacity(0.5),
                                    Color.gray.opacity(0.3)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: verificationCode.count == 6 && !isLoading ? Color.black.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
                    }
                    .disabled(verificationCode.count != 6 || isLoading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                }
            }
            .fullScreenCover(isPresented: $showingMainApp) {
                ContentView()
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                startTimer()
                sendInitialVerificationCode()
                // Focus the code field automatically
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isCodeFieldFocused = true
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func sendInitialVerificationCode() {
        Task {
            do {
                let response = try await authService.sendEmailVerificationCode(email: campusEmail)
                if !response.success {
                    await MainActor.run {
                        errorMessage = response.message
                        showingError = true
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func verifyCode() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let response = try await authService.verifyEmailCode(email: campusEmail, code: verificationCode)
                
                await MainActor.run {
                    isLoading = false
                    
                    if response.success {
                        // Store the token if needed
                        if let token = response.token {
                            // Save token to UserDefaults or Keychain
                            UserDefaults.standard.set(token, forKey: "authToken")
                        }
                        showingMainApp = true
                    } else {
                        errorMessage = response.message
                        showingError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func resendCode() {
        guard !isResending else { return }
        
        isResending = true
        errorMessage = ""
        
        Task {
            do {
                let response = try await authService.sendEmailVerificationCode(email: campusEmail)
                
                await MainActor.run {
                    isResending = false
                    
                    if response.success {
                        startTimer()
                    } else {
                        errorMessage = response.message
                        showingError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isResending = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
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