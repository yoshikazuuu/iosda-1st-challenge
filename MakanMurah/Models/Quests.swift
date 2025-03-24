//
//  Quest.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 21/03/25.
//

import Foundation
import SwiftData

enum QuestType: String, Codable, CaseIterable {
    case exploration = "Exploration"
    case foodTasting = "Food Tasting"
    case budgetMaster = "Budget Master"
    case favoriteCollector = "Favorite Collector"
    case areaSpecialist = "Area Specialist"
}

enum QuestStatus: String, Codable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"
}

@Model
final class Quest {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var desc: String
    var type: QuestType
    var requiredCount: Int
    var reward: Int // Points earned when completing this quest
    var isActive: Bool = true
    
    @Relationship(deleteRule: .cascade) var milestones: [Milestone] = []
    
    init(
        id: UUID = UUID(),
        title: String,
        desc: String,
        type: QuestType,
        requiredCount: Int,
        reward: Int,
        isActive: Bool = true,
        milestones: [Milestone] = []
    ) {
        self.id = id
        self.title = title
        self.desc = desc
        self.type = type
        self.requiredCount = requiredCount
        self.reward = reward
        self.isActive = isActive
        self.milestones = milestones
    }
}

@Model
final class Milestone {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var threshold: Int
    var reward: Int
    var completed: Bool = false
    
    @Relationship var quest: Quest?
    
    init(
        id: UUID = UUID(),
        title: String,
        threshold: Int,
        reward: Int,
        completed: Bool = false,
        quest: Quest? = nil
    ) {
        self.id = id
        self.title = title
        self.threshold = threshold
        self.reward = reward
        self.completed = completed
        self.quest = quest
    }
}

@Model
final class UserProgress {
    @Attribute(.unique) var id: UUID = UUID()
    var totalPoints: Int = 0
    var currentRank: Rank
    var stallsVisited: [UUID] = [] // Stall IDs
    var areasExplored: [UUID] = [] // GOPArea IDs
    var dishesEaten: [UUID] = [] // Menu IDs
    var budgetMealsFound: Int = 0
    var budgetStallsFound: [UUID]? = [] // Track budget stalls by ID
    var favoritesCount: Int = 0
    var reviewsSubmitted: Int = 0
    
    @Relationship(deleteRule: .cascade) var completedQuests: [UUID] = [] // Quest IDs
    
    init(
        id: UUID = UUID(),
        totalPoints: Int = 0,
        currentRank: Rank = .newbie,
        stallsVisited: [UUID] = [],
        areasExplored: [UUID] = [],
        dishesEaten: [UUID] = [],
        budgetMealsFound: Int = 0,
        budgetStallsFound: [UUID]? = [],
        favoritesCount: Int = 0,
        reviewsSubmitted: Int = 0,
        completedQuests: [UUID] = []
    ) {
        self.id = id
        self.totalPoints = totalPoints
        self.currentRank = currentRank
        self.stallsVisited = stallsVisited
        self.areasExplored = areasExplored
        self.dishesEaten = dishesEaten
        self.budgetMealsFound = budgetMealsFound
        self.budgetStallsFound = budgetStallsFound
        self.favoritesCount = favoritesCount
        self.reviewsSubmitted = reviewsSubmitted
        self.completedQuests = completedQuests
    }
    
    func progressForQuest(questType: QuestType) -> Int {
        switch questType {
        case .exploration:
            return stallsVisited.count
        case .foodTasting:
            return dishesEaten.count
        case .budgetMaster:
            return budgetMealsFound
        case .favoriteCollector:
            return favoritesCount
        case .areaSpecialist:
            return areasExplored.count
        }
    }
}

enum Rank: String, Codable, CaseIterable {
    case newbie = "Food Explorer"
    case bronze = "Culinary Adventurer"
    case silver = "Taste Connoisseur"
    case gold = "Food Maestro"
    case platinum = "Gastronomy Legend"
    
    var pointsRequired: Int {
        switch self {
        case .newbie: return 0
        case .bronze: return 100
        case .silver: return 500
        case .gold: return 1000
        case .platinum: return 2500
        }
    }
    
    var icon: String {
        switch self {
        case .newbie: return "fork.knife.circle"
        case .bronze: return "medal.fill"
        case .silver: return "medal.fill"
        case .gold: return "crown.fill"
        case .platinum: return "star.fill"
        }
    }
}

// Extension with sample quests
extension Quest {
    static let samples: [Quest] = [
        Quest(
            title: "GOP Explorer",
            desc: "Visit food stalls in different GOP areas",
            type: .exploration,
            requiredCount: 10,
            reward: 150,
            milestones: [
                Milestone(title: "First Step", threshold: 1, reward: 10),
                Milestone(title: "Getting Started", threshold: 3, reward: 25),
                Milestone(title: "Halfway There", threshold: 5, reward: 50),
                Milestone(title: "Almost Complete", threshold: 8, reward: 75)
            ]
        ),
        Quest(
            title: "Budget Foodie",
            desc: "Find meals under 10k rupiah",
            type: .budgetMaster,
            requiredCount: 15,
            reward: 200,
            milestones: [
                Milestone(title: "Bargain Hunter", threshold: 3, reward: 15),
                Milestone(title: "Savings Expert", threshold: 8, reward: 40),
                Milestone(title: "Budget Master", threshold: 12, reward: 60)
            ]
        ),
        Quest(
            title: "Area Specialist: GOP 1",
            desc: "Visit 5 different stalls in GOP 1",
            type: .areaSpecialist,
            requiredCount: 5,
            reward: 100,
            milestones: [
                Milestone(title: "GOP 1 Beginner", threshold: 1, reward: 15),
                Milestone(title: "GOP 1 Regular", threshold: 3, reward: 35),
                Milestone(title: "GOP 1 Expert", threshold: 5, reward: 50)
            ]
        ),
        Quest(
            title: "Taste Tester",
            desc: "Try 20 different dishes across various stalls",
            type: .foodTasting,
            requiredCount: 20,
            reward: 250,
            milestones: [
                Milestone(title: "Curious Taster", threshold: 5, reward: 20),
                Milestone(title: "Adventurous Eater", threshold: 10, reward: 50),
                Milestone(title: "Food Enthusiast", threshold: 15, reward: 80)
            ]
        ),
        Quest(
            title: "Favorite Collector",
            desc: "Add stalls to your favorites collection",
            type: .favoriteCollector,
            requiredCount: 10,
            reward: 150,
            milestones: [
                Milestone(title: "First Favorite", threshold: 1, reward: 15),
                Milestone(title: "Growing Collection", threshold: 5, reward: 40),
                Milestone(title: "Favorite Connoisseur", threshold: 8, reward: 60)
            ]
        )
    ]
}
