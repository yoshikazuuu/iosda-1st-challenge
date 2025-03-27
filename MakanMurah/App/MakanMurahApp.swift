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
            FoodMenu.self,
            GOPArea.self,
            Quest.self,
            Milestone.self,
            UserProgress.self
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
            
            var menus: [FoodMenu] = []
            for (menuName, price, menuDesc, dietType, imageName, menuType) in menuItems {
                let menu = FoodMenu(
                    name: menuName,
                    price: price,
                    desc: menuDesc,
                    image: loadImage(named: imageName),
                    type: ["Main"],
                    dietType: dietType,
                    menuType: menuType,
                    stalls: stall
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
        
        // Seed Quests data
        await seedQuestsData(context: context)
        
        do {
            try context.save()
            print("Data seeded successfully.")
        } catch {
            print("Failed to seed data: \(error)")
        }
    }
    
    // Add Quest seeding
    static func seedQuestsData(context: ModelContext) async {
        // Check if quests already exist
        let questCount = try? context.fetchCount(FetchDescriptor<Quest>())
        if (questCount ?? 0) > 0 {
            print("Quest data already seeded, skipping.")
            return
        }
        
        // GOP Explorer Quest
        let gopExplorerQuest = Quest(
            title: "GOP Explorer",
            desc: "Visit food stalls in different GOP areas",
            type: .exploration,
            requiredCount: 10,
            reward: 150
        )
        
        let explorerMilestones = [
            Milestone(title: "First Step", threshold: 1, reward: 10, quest: gopExplorerQuest),
            Milestone(title: "Getting Started", threshold: 3, reward: 25, quest: gopExplorerQuest),
            Milestone(title: "Halfway There", threshold: 5, reward: 50, quest: gopExplorerQuest),
            Milestone(title: "Almost Complete", threshold: 8, reward: 75, quest: gopExplorerQuest)
        ]
        
        gopExplorerQuest.milestones = explorerMilestones
        
        // Budget Foodie Quest
        let budgetFoodieQuest = Quest(
            title: "Budget Foodie",
            desc: "Find meals under 10k rupiah",
            type: .budgetMaster,
            requiredCount: 15,
            reward: 200
        )
        
        let budgetMilestones = [
            Milestone(title: "Bargain Hunter", threshold: 3, reward: 15, quest: budgetFoodieQuest),
            Milestone(title: "Savings Expert", threshold: 8, reward: 40, quest: budgetFoodieQuest),
            Milestone(title: "Budget Master", threshold: 12, reward: 60, quest: budgetFoodieQuest)
        ]
        
        budgetFoodieQuest.milestones = budgetMilestones
        
        // Area Specialist Quest
        let areaSpecialistQuest = Quest(
            title: "Area Specialist: GOP 1",
            desc: "Visit 5 different stalls in GOP 1",
            type: .areaSpecialist,
            requiredCount: 5,
            reward: 100
        )
        
        let areaMilestones = [
            Milestone(title: "GOP 1 Beginner", threshold: 1, reward: 15, quest: areaSpecialistQuest),
            Milestone(title: "GOP 1 Regular", threshold: 3, reward: 35, quest: areaSpecialistQuest),
            Milestone(title: "GOP 1 Expert", threshold: 5, reward: 50, quest: areaSpecialistQuest)
        ]
        
        areaSpecialistQuest.milestones = areaMilestones
        
        // Taste Tester Quest
        let tasteTesterQuest = Quest(
            title: "Taste Tester",
            desc: "Try 20 different dishes across various stalls",
            type: .foodTasting,
            requiredCount: 20,
            reward: 250
        )
        
        let tasteMilestones = [
            Milestone(title: "Curious Taster", threshold: 5, reward: 20, quest: tasteTesterQuest),
            Milestone(title: "Adventurous Eater", threshold: 10, reward: 50, quest: tasteTesterQuest),
            Milestone(title: "Food Enthusiast", threshold: 15, reward: 80, quest: tasteTesterQuest)
        ]
        
        tasteTesterQuest.milestones = tasteMilestones
        
        // Favorite Collector Quest
        let favoriteCollectorQuest = Quest(
            title: "Favorite Collector",
            desc: "Add stalls to your favorites collection",
            type: .favoriteCollector,
            requiredCount: 10,
            reward: 150
        )
        
        let favoritesMilestones = [
            Milestone(title: "First Favorite", threshold: 1, reward: 15, quest: favoriteCollectorQuest),
            Milestone(title: "Growing Collection", threshold: 5, reward: 40, quest: favoriteCollectorQuest),
            Milestone(title: "Favorite Connoisseur", threshold: 8, reward: 60, quest: favoriteCollectorQuest)
        ]
        
        favoriteCollectorQuest.milestones = favoritesMilestones
        
        // Create default user progress
        let userProgress = UserProgress()
        
        // Insert all quests and milestones into the context
        context.insert(gopExplorerQuest)
        context.insert(budgetFoodieQuest)
        context.insert(areaSpecialistQuest)
        context.insert(tasteTesterQuest)
        context.insert(favoriteCollectorQuest)
        context.insert(userProgress)
        
        for milestone in explorerMilestones + budgetMilestones + areaMilestones + tasteMilestones + favoritesMilestones {
            context.insert(milestone)
        }
        
        print("Quest data seeded successfully.")
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
        let schema = Schema([
            Stalls.self,
            FoodMenu.self,
            GOPArea.self,
            Quest.self,
            Milestone.self,
            UserProgress.self
        ])
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
