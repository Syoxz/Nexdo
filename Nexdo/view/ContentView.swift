import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }.tag(0)
            
            BacklogView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Backlog")
                }
                .tag(1)
            
            SprintView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Sprint")
                }.tag(2)
        }
        .accentColor(.blue)
    }
}
