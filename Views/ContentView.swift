import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .tag(0)
                    
                    EventsView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Events")
                        }
                        .tag(1)
                    
                    DiningMenuView()
                        .tabItem {
                            Image(systemName: "fork.knife")
                            Text("Dining")
                        }
                        .tag(2)
                    
                    CampusMapView()
                        .tabItem {
                            Image(systemName: "map.fill")
                            Text("Map")
                        }
                        .tag(3)
                    
                    MoreView()
                        .tabItem {
                            Image(systemName: "ellipsis")
                            Text("More")
                        }
                        .tag(4)
                }
                .accentColor(DesignSystem.Colors.orange)
                .onAppear {
                    // Set tab bar appearance
                    let appearance = UITabBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor.systemBackground
                    
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            } else {
                LoginView()
            }
        }
        .onAppear {
            // Check authentication status
            authService.checkAuthenticationStatus()
        }
    }
}
