import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            StallsTabView()
                .tabItem {
                    Label("Foods", systemImage: "fork.knife")
                }
            
            QuestsTabView()
                .tabItem {
                    Label("Quests", systemImage: "pencil.and.list.clipboard")
                }
        }
    }
}
