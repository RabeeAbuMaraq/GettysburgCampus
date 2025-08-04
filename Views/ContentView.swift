import SwiftUI

struct ContentView: View {
    @StateObject private var userManager = UserManager.shared
    
    var body: some View {
        Group {
            // Temporarily skip authentication for development
            MainAppView()
            
            // Uncomment this when you want authentication back:
            // if userManager.isUserLoggedIn() {
            //     MainAppView()
            // } else {
            //     LoginView()
            // }
        }
    }
}

struct MainAppView: View {
    @StateObject private var userManager = UserManager.shared
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            DiningMenuView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Dining")
                }
            
            EventsView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Events")
                }
            
            CampusMapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
            
            MoreView()
                .tabItem {
                    Image(systemName: "ellipsis.circle.fill")
                    Text("More")
                }
        }
        .accentColor(Color.primaryAccent)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Sign Out") {
                    userManager.signOut()
                }
                .foregroundColor(Color.primaryAccent)
            }
        }
    }
}
