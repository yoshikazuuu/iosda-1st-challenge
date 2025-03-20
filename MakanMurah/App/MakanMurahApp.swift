//
//  MakanMurahApp.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 19/03/25.
//

import SwiftUI
import UIKit
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
        
        // Create sample data with prices in IDR
        let stallsData: [(String, String, Double, Double, Double, GOPArea, String, [(String, Double, String, [String], MenuType)])] = [
                ("Warung Pojok", "Traditional Indonesian food", 8_000, 25_000, 15_000, .gop1, "warung_pojok", [
                ("Nasi Goreng", 12_000, "Delicious fried rice", ["Rice", "Egg", "Chicken"], .indonesian),
                ("Sate Ayam", 18_000, "Grilled chicken skewers", ["Chicken", "Peanut Sauce"], .indonesian),
                ("Rendang", 20_000, "Spicy beef stew", ["Beef", "Coconut Milk", "Spices"], .indonesian)
            ]),
            ("Burger Joint", "Classic American burgers", 10_000, 20_000, 15_000, .gop2, "burger_joint", [
                ("Classic Burger", 14_000, "Beef patty, lettuce, tomato, cheese", ["Beef", "Lettuce", "Tomato", "Cheese"], .western),
                ("Veggie Burger", 12_000, "Grilled vegetable patty", ["Vegetables", "Lettuce"], .western),
                ("BBQ Bacon Burger", 16_000, "Bacon, BBQ sauce, and cheese", ["Bacon", "BBQ Sauce", "Cheese"], .western)
            ]),
            ("Sushi Place", "Authentic Japanese sushi", 15_000, 50_000, 30_000, .gop3, "sushi_place", [
                ("California Roll", 10_000, "Crab, avocado, and cucumber", ["Crab", "Avocado", "Cucumber"], .japanese),
                ("Salmon Sashimi", 20_000, "Fresh salmon slices", ["Salmon"], .japanese),
                ("Tempura", 15_000, "Battered and fried vegetables", ["Vegetables", "Batter"], .japanese)
            ]),
            ("Taco Stand", "Mexican street tacos", 5_000, 15_000, 10_000, .gop1, "taco_stand", [
                ("Chicken Taco", 8_000, "Spicy chicken taco", ["Chicken", "Tortilla", "Salsa"], .indonesian),
                ("Beef Taco", 10_000, "Beef taco with cheese", ["Beef", "Cheese", "Tortilla"], .indonesian),
                ("Fish Taco", 12_000, "Crispy fish with cabbage", ["Fish", "Cabbage", "Salsa"], .indonesian)
            ]),
            ("Pasta House", "Italian pasta dishes", 12_000, 30_000, 20_000, .gop2, "pasta_house", [
                ("Spaghetti Carbonara", 15_000, "Creamy pasta with bacon", ["Pasta", "Bacon", "Egg"], .western),
                ("Penne Arrabbiata", 12_000, "Spicy tomato sauce pasta", ["Pasta", "Tomato", "Chili"], .western),
                ("Fettuccine Alfredo", 18_000, "Creamy fettuccine with parmesan", ["Pasta", "Cream", "Parmesan"], .western)
            ]),
            ("Café Delight", "Cozy café with pastries", 3_000, 10_000, 6_000, .gop3, "cafe_delight", [
                ("Croissant", 3_000, "Flaky buttery pastry", ["Flour", "Butter"], .western),
                ("Latte", 4_000, "Creamy coffee drink", ["Coffee", "Milk"], .western),
                ("Chocolate Cake", 5_000, "Rich chocolate cake", ["Chocolate", "Flour", "Sugar"], .western)
            ]),
            ("Dim Sum House", "Chinese dim sum", 8_000, 25_000, 16_000, .gop4, "dim_sum_house", [
                ("Shrimp Dumplings", 10_000, "Steamed shrimp dumplings", ["Shrimp", "Dough"], .chinese),
                ("Pork Buns", 12_000, "Soft buns with pork filling", ["Pork", "Dough"], .chinese),
                ("Spring Rolls", 8_000, "Crispy rolls with vegetables", ["Vegetables", "Dough"], .chinese)
            ]),
            ("Korean BBQ", "Grilled Korean dishes", 15_000, 40_000, 25_000, .gop5, "korean_bbq", [
                ("Bulgogi", 20_000, "Marinated beef", ["Beef", "Soy Sauce"], .korean),
                ("Kimchi", 5_000, "Spicy fermented vegetables", ["Cabbage", "Chili"], .korean),
                ("Galbi", 25_000, "Grilled short ribs", ["Beef Ribs", "Marinade"], .korean)
            ]),
            ("Ice Cream Parlor", "Delicious ice cream", 2_000, 8_000, 5_000, .gop1, "ice_cream_parlor", [
                ("Vanilla Ice Cream", 3_000, "Classic vanilla flavor", ["Milk", "Sugar"], .western),
                ("Chocolate Sundae", 5_000, "Chocolate ice cream with toppings", ["Chocolate", "Nuts"], .western),
                ("Strawberry Sorbet", 4_000, "Refreshing strawberry sorbet", ["Strawberries", "Sugar"], .western)
            ]),
            ("Salad Bar", "Fresh salads and bowls", 5_000, 15_000, 10_000, .gop2, "salad_bar", [
                ("Caesar Salad", 8_000, "Romaine lettuce with dressing", ["Lettuce", "Croutons"], .western),
                ("Quinoa Bowl", 10_000, "Healthy quinoa with veggies", ["Quinoa", "Vegetables"], .western),
                ("Greek Salad", 9_000, "Salad with feta and olives", ["Tomato", "Cucumber", "Feta"], .western)
            ]),
            ("Bakery Bliss", "Freshly baked goods", 1_000, 15_000, 8_000, .gop3, "bakery_bliss", [
                ("Baguette", 2_000, "Crispy French bread", ["Flour", "Water"], .western),
                ("Chocolate Croissant", 4_000, "Croissant filled with chocolate", ["Flour", "Chocolate"], .western),
                ("Cheese Danish", 3_000, "Pastry with cream cheese filling", ["Flour", "Cheese"], .western)
            ]),
            ("Pizza Place", "Delicious pizzas", 8_000, 30_000, 18_000, .gop4, "pizza_place", [
                ("Margherita Pizza", 10_000, "Classic pizza with tomato and basil", ["Dough", "Tomato", "Basil"], .western),
                ("Pepperoni Pizza", 12_000, "Pizza topped with pepperoni", ["Dough", "Pepperoni"], .western),
                ("BBQ Chicken Pizza", 15_000, "Pizza with BBQ chicken and onions", ["Dough", "Chicken", "BBQ Sauce"], .western)
            ]),
            ("Smoothie Bar", "Healthy smoothies", 5_000, 12_000, 8_000, .gop5, "smoothie_bar", [
                ("Berry Blast", 6_000, "Mixed berry smoothie", ["Berries", "Yogurt"], .western),
                ("Tropical Delight", 8_000, "Mango and pineapple smoothie", ["Mango", "Pineapple"], .western),
                ("Green Detox", 7_000, "Spinach and kale smoothie", ["Spinach", "Kale"], .western)
            ]),
            ("Grill House", "Grilled meats and sides", 10_000, 35_000, 20_000, .gop1, "grill_house", [
                ("Grilled Chicken", 15_000, "Marinated grilled chicken", ["Chicken", "Spices"], .western),
                ("Steak Frites", 25_000, "Grilled steak with fries", ["Steak", "Potatoes"], .western),
                ("Grilled Vegetables", 10_000, "Assorted grilled vegetables", ["Vegetables"], .western)
            ])
        ]
        
        var stalls: [Stalls] = []
        
        
        for (name, desc, minPrice, maxPrice, avgPrice, area, imageName, menuItems) in stallsData {
            let stall = Stalls(
                name: name,
                desc: desc,
                minimumPrice: minPrice,
                maximumPrice: maxPrice,
                averagePrice: avgPrice,
                area: area,
                menu: [],
                isFavorite: false,
                image: loadImage(named: imageName) // Load stall image
            )

            var menus: [Menu] = []
            for (menuName, price, menuDesc, ingredients, menuType) in menuItems {
                let menu = Menu(
                    name: menuName,
                    price: price,
                    desc: menuDesc,
                    type: ["Main"],
                    ingredients: ingredients,
                    menuType: menuType,
                    stalls: stall // Establish relationship
                )
                menus.append(menu)
            }

            stall.menu = menus // Establish relationship
            stalls.append(stall)
        }

        // Insert all stalls and their menus into the context
        for stall in stalls {
            context.insert(stall)
            for menu in stall.menu {
                context.insert(menu)
            }
        }

        do {
            try context.save()
            print("Data seeded successfully.")
        } catch {
            print("Failed to seed data: \(error)")
        }
    }

    // Helper function to load images
    private static func loadImage(named imageName: String) -> Data? {
        guard let image = UIImage(named: imageName) else {
            print("Image named \(imageName) not found.")
            return nil
        }
        return image.pngData()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previewContainer: ModelContainer = {
        // Create an in-memory model container for seeding previews
        let schema = Schema([Stalls.self, Menu.self])
        let modelConfiguration =
        ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container: ModelContainer
        
        do {
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create in-memory ModelContainer: \(error)")
        }
        
        // Seed the container asynchronously.
        Task {
            await MakanMurahApp.seedData(container: container)
        }
        
        return container
    }()
    
    static var previews: some View {
        ContentView()
            .modelContainer(previewContainer)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Stalls.self, Menu.self], inMemory: true)
}
