import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.userManager.isAuthenticated {
                TabView(selection: $appState.selectedTab) {
                    HomeView()
                        .tabItem {
                            Image(systemName: AppTab.home.icon)
                            Text(AppTab.home.title)
                        }
                        .tag(AppTab.home.rawValue)
                    
                    EventsView()
                        .tabItem {
                            Image(systemName: AppTab.events.icon)
                            Text(AppTab.events.title)
                        }
                        .tag(AppTab.events.rawValue)
                    
                    DiningView()
                        .tabItem {
                            Image(systemName: AppTab.dining.icon)
                            Text(AppTab.dining.title)
                        }
                        .tag(AppTab.dining.rawValue)
                    
                    CampusMapView()
                        .tabItem {
                            Image(systemName: AppTab.map.icon)
                            Text(AppTab.map.title)
                        }
                        .tag(AppTab.map.rawValue)
                    
                    MoreView()
                        .tabItem {
                            Image(systemName: AppTab.more.icon)
                            Text(AppTab.more.title)
                        }
                        .tag(AppTab.more.rawValue)
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
    }
}
