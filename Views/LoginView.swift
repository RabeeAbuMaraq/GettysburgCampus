import SwiftUI

struct LoginView: View {
    @StateObject private var userManager = UserManager.shared
    @State private var showingSignUp = false
    @State private var showingSignIn = false
    
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
                    // Floating orbs
                    Circle()
                        .fill(Color.primaryAccent.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .blur(radius: 50)
                        .offset(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
                    
                    Circle()
                        .fill(Color.primaryAccent.opacity(0.1))
                        .frame(width: 150, height: 150)
                        .blur(radius: 40)
                        .offset(x: geometry.size.width * 0.1, y: geometry.size.height * 0.7)
                }
            }
            
            VStack(spacing: 0) {
                // Header with premium logo
                VStack(spacing: 32) {
                    // Premium logo with glass effect
                    ZStack {
                                                    Circle()
                                .fill(Color.cardBackground)
                                .frame(width: 140, height: 140)
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
                            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                        
                        // App icon (building columns for clock tower)
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 60, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.white,
                                        Color.primaryAccent
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .padding(.top, 80)
                    
                    // App title and tagline
                    VStack(spacing: 16) {
                        Text("Gettysburg Campus")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.white,
                                        Color.primaryAccent
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Your complete campus companion")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Campus life with every feature")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
                
                // Action buttons with glass effect
                VStack(spacing: 20) {
                    // Create Account Button
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showingSignUp = true
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Create Account")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                    }
                    .modernButton(.primary)
                    .scaleEffect(showingSignUp ? 0.95 : 1.0)
                    
                    // Sign In Button
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showingSignIn = true
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Sign In")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Color.primaryAccent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
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
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .scaleEffect(showingSignIn ? 0.95 : 1.0)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
        .sheet(isPresented: $showingSignIn) {
            SignInView()
        }
    }
} 