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
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.98, green: 0.98, blue: 1.0)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            // Clock Tower Icon
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "building.columns.fill")
                                    .font(.system(size: 32, weight: .light))
                                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                            }
                            
                            VStack(spacing: 8) {
                                Text("Create Account")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                                
                                Text("Join the Gettysburg community")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Form Fields
                        VStack(spacing: 24) {
                            // Name Fields
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("First Name")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                                    
                                    TextField("Enter first name", text: $firstName)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Last Initial")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                                    
                                    TextField("L", text: $lastInitial)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .textInputAutocapitalization(.characters)
                                }
                            }
                            
                            // Class Year
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Class Year")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                                
                                Menu {
                                    ForEach(classYears, id: \.self) { year in
                                        Button(year) {
                                            classYear = year
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(classYear.isEmpty ? "Select Year" : classYear)
                                            .foregroundColor(classYear.isEmpty ? .gray : Color(red: 0.1, green: 0.2, blue: 0.4))
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                            
                            // Campus Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Campus Email")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                                
                                TextField("username@gettysburg.edu", text: $campusEmail)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Continue Button
                        Button(action: {
                            if isValidForm() {
                                showingEmailVerification = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Continue")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: isValidForm() ? [
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
                            .shadow(color: isValidForm() ? Color.black.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
                        }
                        .disabled(!isValidForm())
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
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
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
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
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func isValidForm() -> Bool {
        !firstName.isEmpty &&
        !lastInitial.isEmpty &&
        !classYear.isEmpty &&
        !campusEmail.isEmpty &&
        campusEmail.contains("@gettysburg.edu")
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

struct UserData {
    let firstName: String
    let lastInitial: String
    let classYear: String
    let campusEmail: String
    let phoneNumber: String
} 