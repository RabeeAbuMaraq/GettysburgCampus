import Foundation
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private let baseURL = "http://10.0.0.204:3000" // Your computer's IP address
    
    private init() {}
    
    // MARK: - Sign Up
    func signUp(userData: UserData) async throws -> SignUpResponse {
        let url = URL(string: "\(baseURL)/auth/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let signUpData = SignUpRequest(
            firstName: userData.firstName,
            lastInitial: userData.lastInitial,
            classYear: userData.classYear,
            campusEmail: userData.campusEmail
        )
        
        request.httpBody = try JSONEncoder().encode(signUpData)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            print("📡 API Response Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                return try JSONDecoder().decode(SignUpResponse.self, from: data)
            } else {
                let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                throw AuthError.serverError(httpResponse.statusCode, errorData?.message ?? "Server error")
            }
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ Network Error: \(error.localizedDescription)")
            throw AuthError.networkError
        }
    }
    
    // MARK: - Send Email Verification Code
    func sendEmailVerificationCode(email: String) async throws -> VerificationResponse {
        let url = URL(string: "\(baseURL)/auth/send-email-verification")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let verificationRequest = EmailVerificationRequest(email: email)
        request.httpBody = try JSONEncoder().encode(verificationRequest)
        
        print("📧 Sending verification code to: \(email)")
        print("🌐 URL: \(url)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            print("📡 API Response Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                let result = try JSONDecoder().decode(VerificationResponse.self, from: data)
                print("✅ Verification code sent successfully")
                return result
            } else {
                let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                throw AuthError.serverError(httpResponse.statusCode, errorData?.message ?? "Server error")
            }
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ Network Error: \(error.localizedDescription)")
            throw AuthError.networkError
        }
    }
    
    // MARK: - Verify Email Code
    func verifyEmailCode(email: String, code: String) async throws -> VerificationResponse {
        let url = URL(string: "\(baseURL)/auth/verify-email")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let verifyRequest = VerifyEmailRequest(email: email, code: code)
        request.httpBody = try JSONEncoder().encode(verifyRequest)
        
        print("🔐 Verifying code for: \(email)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            print("📡 API Response Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                let result = try JSONDecoder().decode(VerificationResponse.self, from: data)
                print("✅ Email verified successfully")
                return result
            } else {
                let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                throw AuthError.serverError(httpResponse.statusCode, errorData?.message ?? "Server error")
            }
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ Network Error: \(error.localizedDescription)")
            throw AuthError.networkError
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String) async throws -> SignInResponse {
        let url = URL(string: "\(baseURL)/auth/signin")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let signInRequest = SignInRequest(email: email)
        request.httpBody = try JSONEncoder().encode(signInRequest)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            print("📡 API Response Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                return try JSONDecoder().decode(SignInResponse.self, from: data)
            } else {
                let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                throw AuthError.serverError(httpResponse.statusCode, errorData?.message ?? "Server error")
            }
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ Network Error: \(error.localizedDescription)")
            throw AuthError.networkError
        }
    }
}

// MARK: - Request/Response Models
struct SignUpRequest: Codable {
    let firstName: String
    let lastInitial: String
    let classYear: String
    let campusEmail: String
}

struct SignUpResponse: Codable {
    let success: Bool
    let message: String
    let userId: String?
}

struct EmailVerificationRequest: Codable {
    let email: String
}

struct VerifyEmailRequest: Codable {
    let email: String
    let code: String
}

struct VerificationResponse: Codable {
    let success: Bool
    let message: String
    let token: String?
}

struct SignInRequest: Codable {
    let email: String
}

struct SignInResponse: Codable {
    let success: Bool
    let message: String
    let token: String?
    let user: User?
}

struct User: Codable {
    let id: String
    let firstName: String
    let lastInitial: String
    let classYear: String
    let campusEmail: String
}

struct ErrorResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - Error Types
enum AuthError: Error, LocalizedError {
    case invalidResponse
    case serverError(Int, String)
    case invalidCredentials
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .invalidCredentials:
            return "Invalid credentials"
        case .networkError:
            return "Could not connect to the server. Please check your internet connection and try again."
        }
    }
} 