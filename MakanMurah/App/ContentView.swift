import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            StallsTabView()
                .tabItem {
                    Label("Stalls", systemImage: "house.fill")
                }
            
            QuestsTabView()
                .tabItem {
                    Label("Quests", systemImage: "map.fill")
                }
        }
    }
}
