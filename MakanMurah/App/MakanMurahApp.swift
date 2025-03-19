//
//  MakanMurahApp.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 19/03/25.
//

import SwiftUI
import SwiftData
import CoreLocation

@main
struct MakanMurahApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Stalls.self,
            Menu.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        let container: ModelContainer
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Seed data if needed
            Task {
                await seedData(container: container)
            }

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }

    static func seedData(container: ModelContainer) async {
        let context = ModelContext(container)

        // Check if data already exists (optional, but good practice)
        let stallCount = try? context.fetchCount(FetchDescriptor<Stalls>())
        if (stallCount ?? 0) > 0 {
            print("Data already seeded, skipping.")
            return
        }

        // Create sample data
        let stall1 = Stalls(
            name: "Warung Pojok",
            desc: "Traditional Indonesian food",
            minimumPrice: 8.0,
            maximumPrice: 25.0,
            averagePrice: 15.0,
            area: .gop1, // Use the enum
            menu: [],
            isFavorite: true
        )

        let menu1 = Menu(
            name: "Nasi Goreng",
            price: 12.0,
            desc: "Delicious fried rice",
            type: ["Main"],
            ingredients: ["Rice", "Egg", "Chicken"], // Corrected spelling
            menuType: .indonesian,
            stalls: stall1
        )

        let menu2 = Menu(
            name: "Sate Ayam",
            price: 18.0,
            desc: "Grilled chicken skewers",
            type: ["Main"],
            ingredients: ["Chicken", "Peanut Sauce"], 
            menuType: .indonesian,
            stalls: stall1
        )

        stall1.menu = [menu1, menu2] // Establish relationship

        let stall2 = Stalls(
            name: "Burger Joint",
            desc: "Classic American burgers",
            minimumPrice: 10.0,
            maximumPrice: 20.0,
            averagePrice: 15.0,
            area: .gop2, // Use the enum
            menu: [],
            isFavorite: false
        )

        let menu3 = Menu(
            name: "Classic Burger",
            price: 14.0,
            desc: "Beef patty, lettuce, tomato, cheese",
            type: ["Main"],
            ingredients: ["Beef", "Lettuce", "Tomato", "Cheese"],
            menuType: .western,
            stalls: stall2
        )

        stall2.menu = [menu3] // Establish relationship

        context.insert(stall1)
        context.insert(stall2)
        context.insert(menu1)
        context.insert(menu2)
        context.insert(menu3)

        do {
            try context.save()
            print("Data seeded successfully.")
        } catch {
            print("Failed to seed data: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: [Stalls.self, Menu.self], inMemory: true)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Stalls.self, Menu.self], inMemory: true)
}
