import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            CampusMapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
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

            MoreView()
                .tabItem {
                    Image(systemName: "ellipsis.circle")
                    Text("More")
                }
        }
    }
}
