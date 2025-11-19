import Foundation
import Combine

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    // DEVELOPMENT: Bypass authentication
    @Published var isAuthenticated = true
    @Published var currentUser: User?
    
    private let userDefaults = UserDefaults.standard
    private let authTokenKey = "authToken"
    private let userDataKey = "userData"
    
    init() {
        // DEVELOPMENT: Skip loading user from storage
        // loadUserFromStorage()
    }
    
    struct User: Codable {
        let email: String
        let firstName: String
        let lastInitial: String
        let classYear: String
        let token: String
        let createdAt: Date
    }
    
    func saveUser(_ user: User) {
        currentUser = user
        isAuthenticated = true
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: userDataKey)
        }
        userDefaults.set(user.token, forKey: authTokenKey)
    }
    
    func loadUserFromStorage() {
        if let userData = userDefaults.data(forKey: userDataKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isAuthenticated = true
        }
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        
        // Clear from UserDefaults
        userDefaults.removeObject(forKey: userDataKey)
        userDefaults.removeObject(forKey: authTokenKey)
    }
    
    func getAuthToken() -> String? {
        return userDefaults.string(forKey: authTokenKey)
    }
    
    func isUserLoggedIn() -> Bool {
        return isAuthenticated && currentUser != nil
    }
} 