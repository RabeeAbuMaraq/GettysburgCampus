import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = ""
    @State private var lastInitial = ""
    @State private var classYear = ""
    @State private var campusEmail = ""
    @State private var showingEmailVerification = false
    
    let classYears = ["2024", "2025", "2026", "2027", "2028"]
    
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
                            
                            Image(systemName: "building.columns.fill")
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
                            Text("Create Account")
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
                            
                            Text("Join the Gettysburg community")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Form Fields
                    VStack(spacing: 24) {
                        // Name Fields
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("First Name")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                TextField("Enter first name", text: $firstName)
                                    .modernTextField()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Last Initial")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                TextField("L", text: $lastInitial)
                                    .textInputAutocapitalization(.characters)
                                    .modernTextField()
                            }
                        }
                        
                        // Class Year
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Class Year")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Menu {
                                ForEach(classYears, id: \.self) { year in
                                    Button(year) {
                                        classYear = year
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(classYear.isEmpty ? "Select Year" : classYear)
                                        .foregroundColor(classYear.isEmpty ? .white.opacity(0.6) : .white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.cardBackground)
                                        .opacity(0.8)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.2),
                                                    Color.white.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                        }
                        
                        // Campus Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Campus Email")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextField("username@gettysburg.edu", text: $campusEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .modernTextField()
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                    
                    // Continue Button
                    Button(action: {
                        if isValidForm() {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showingEmailVerification = true
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                    }
                    .modernButton(.primary, isEnabled: isValidForm())
                    .disabled(!isValidForm())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white.opacity(0.8))
            }
        }
        .sheet(isPresented: $showingEmailVerification) {
            EmailVerificationView(
                userData: UserData(
                    firstName: firstName,
                    lastInitial: lastInitial,
                    classYear: classYear,
                    campusEmail: campusEmail,
                    phoneNumber: ""
                )
            )
        }
    }
    
    private func isValidForm() -> Bool {
        !firstName.isEmpty &&
        !lastInitial.isEmpty &&
        !classYear.isEmpty &&
        !campusEmail.isEmpty &&
        campusEmail.contains("@gettysburg.edu")
    }
}

struct UserData {
    let firstName: String
    let lastInitial: String
    let classYear: String
    let campusEmail: String
    let phoneNumber: String
} 