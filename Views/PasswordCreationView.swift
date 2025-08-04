import SwiftUI

struct PasswordCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userManager = UserManager.shared
    let userData: UserData
    
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingPassword = false
    @State private var showingConfirmPassword = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case password, confirmPassword
    }
    
    var body: some View {
        ZStack {
            // Premium gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.25),
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.15, green: 0.25, blue: 0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated background elements
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.1))
                        .frame(width: 200, height: 200)
                        .blur(radius: 50)
                        .offset(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
                    
                    Circle()
                        .fill(Color(red: 0.1, green: 0.4, blue: 0.8).opacity(0.1))
                        .frame(width: 150, height: 150)
                        .blur(radius: 40)
                        .offset(x: geometry.size.width * 0.1, y: geometry.size.height * 0.7)
                }
            }
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 24) {
                        // Premium logo
                        ZStack {
                            Circle()
                                .fill(Color.cardBackground)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.white.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
                            
                            Image(systemName: "lock.shield")
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color.white,
                                            Color(red: 0.2, green: 0.6, blue: 1.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .padding(.top, 40)
                        
                        VStack(spacing: 12) {
                            Text("Create Your Password")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color.white,
                                            Color(red: 0.2, green: 0.6, blue: 1.0)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Secure your account with a strong password")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.cardBackground)
                                    .opacity(0.8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Password Form
                    VStack(spacing: 24) {
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack {
                                if showingPassword {
                                    TextField("Enter your password", text: $password)
                                        .focused($focusedField, equals: .password)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                        .focused($focusedField, equals: .password)
                                }
                                
                                Button(action: {
                                    showingPassword.toggle()
                                }) {
                                    Image(systemName: showingPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .modernTextField()
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack {
                                if showingConfirmPassword {
                                    TextField("Confirm your password", text: $confirmPassword)
                                        .focused($focusedField, equals: .confirmPassword)
                                } else {
                                    SecureField("Confirm your password", text: $confirmPassword)
                                        .focused($focusedField, equals: .confirmPassword)
                                }
                                
                                Button(action: {
                                    showingConfirmPassword.toggle()
                                }) {
                                    Image(systemName: showingConfirmPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .modernTextField()
                        }
                        
                        // Password Requirements
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password Requirements:")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                RequirementRow(text: "At least 8 characters", isMet: password.count >= 8)
                                RequirementRow(text: "Contains uppercase letter", isMet: password.contains { $0.isUppercase })
                                RequirementRow(text: "Contains lowercase letter", isMet: password.contains { $0.isLowercase })
                                RequirementRow(text: "Contains number", isMet: password.contains { $0.isNumber })
                                RequirementRow(text: "Passwords match", isMet: password == confirmPassword && !confirmPassword.isEmpty)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                    
                    // Create Account Button
                    Button(action: createAccount) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "checkmark.shield")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            Text(isLoading ? "Creating Account..." : "Create Account")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                    }
                    .modernButton(.primary, isEnabled: isValidForm() && !isLoading)
                    .disabled(!isValidForm() || isLoading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
                .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private func isValidForm() -> Bool {
        password.count >= 8 &&
        password.contains { $0.isUppercase } &&
        password.contains { $0.isLowercase } &&
        password.contains { $0.isNumber } &&
        password == confirmPassword &&
        !password.isEmpty
    }
    
    private func createAccount() {
        guard isValidForm() else { return }
        
        isLoading = true
        errorMessage = ""
        
        // Create user account
        let user = UserManager.User(
            email: userData.campusEmail,
            firstName: userData.firstName,
            lastInitial: userData.lastInitial,
            classYear: userData.classYear,
            token: UUID().uuidString, // In real app, this would come from backend
            createdAt: Date()
        )
        
        // Save user to persistent storage
        userManager.saveUser(user)
        
        // Dismiss and go to main app
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

struct RequirementRow: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? Color.green : Color.white.opacity(0.4))
                .font(.system(size: 12))
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isMet ? Color.white.opacity(0.8) : Color.white.opacity(0.5))
        }
    }
} 