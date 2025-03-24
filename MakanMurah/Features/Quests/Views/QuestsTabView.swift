import SwiftUI
import SwiftData

struct QuestsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var quests: [Quest]
    @Query private var userProgress: [UserProgress]
    
    @State private var selectedTab = 0
    @State private var showingCompletionAlert = false
    @State private var completedQuestTitle = ""
    @State private var earnedPoints = 0
    
    private var progress: UserProgress {
        if userProgress.isEmpty {
            let newProgress = UserProgress()
            modelContext.insert(newProgress)
            return newProgress
        }
        return userProgress[0]
    }
    
    var groupedQuests: [QuestType: [Quest]] {
        Dictionary(grouping: quests, by: { $0.type })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Rank header with progress display
                RankHeaderView(progress: progress)
                    .padding(.bottom)
                
                // Tab selector for quest categories
                QuestTabSelector(selectedTab: $selectedTab)
                
                // Quests list grouped by type
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if selectedTab == 0 {
                            // All quests tab
                            ForEach(quests) { quest in
                                QuestCardView(
                                    quest: quest,
                                    progress: progress,
                                    onComplete: {
                                        completeQuest(quest)
                                        completedQuestTitle = quest.title
                                        earnedPoints = quest.reward
                                        showingCompletionAlert = true
                                    }
                                )
                                .padding(.horizontal)
                            }
                            
                            if quests.isEmpty {
                                EmptyStateView(message: "No quests available yet")
                                    .padding(.top, 40)
                            }
                        } else {
                            // Get the selected quest type (adjusted index)
                            let questTypeIndex = selectedTab - 1
                            let selectedQuestType = QuestType.allCases[questTypeIndex]
                            let filteredQuests = groupedQuests[selectedQuestType] ?? []
                            
                            ForEach(filteredQuests) { quest in
                                QuestCardView(
                                    quest: quest,
                                    progress: progress,
                                    onComplete: {
                                        completeQuest(quest)
                                        completedQuestTitle = quest.title
                                        earnedPoints = quest.reward
                                        showingCompletionAlert = true
                                    }
                                )
                                .padding(.horizontal)
                            }
                            
                            if filteredQuests.isEmpty {
                                EmptyQuestView(questType: selectedQuestType)
                                    .padding(.top, 40)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Quests")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: addTestProgress) {
                            Label("Add Test Progress", systemImage: "plus")
                        }
                        Button(action: resetProgress) {
                            Label("Reset Progress", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Quest Completed!", isPresented: $showingCompletionAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You've completed '\(completedQuestTitle)' and earned \(earnedPoints) points!")
            }
        }
        .onAppear {
            checkAndUpdateMilestones()
        }
    }
    
    private func completeQuest(_ quest: Quest) {
        if !progress.completedQuests.contains(quest.id) {
            progress.totalPoints += quest.reward
            progress.completedQuests.append(quest.id)
            
            // Check if a new rank is achieved
            updateRank()
            
            // Mark all milestones as completed
            for milestone in quest.milestones {
                milestone.completed = true
            }
            
            // Save changes
            try? modelContext.save()
        }
    }
    
    private func updateRank() {
        for rank in Rank.allCases.reversed() {
            if progress.totalPoints >= rank.pointsRequired {
                if progress.currentRank != rank {
                    progress.currentRank = rank
                    // Could trigger a rank-up celebration here
                }
                break
            }
        }
    }
    
    private func checkAndUpdateMilestones() {
        var totalReward = 0
        
        for quest in quests {
            let currentProgress = progress.progressForQuest(questType: quest.type)
            
            // Find all eligible milestones
            for milestone in quest.milestones where !milestone.completed && currentProgress >= milestone.threshold {
                milestone.completed = true
                progress.totalPoints += milestone.reward
                totalReward += milestone.reward
            }
        }
        
        if totalReward > 0 {
            updateRank()
            try? modelContext.save()
        }
    }
    
    private func addTestProgress() {
        // For testing - simulate progress in various categories
        if selectedTab == 0 {
            // Add some general progress if "All Quests" is selected
            addVisitedStall()
            checkAndAddBudgetMeal()
        } else {
            // Get the selected quest type with adjusted index
            let questTypeIndex = selectedTab - 1
            let selectedQuestType = QuestType.allCases[questTypeIndex]
            
            switch selectedQuestType {
            case .exploration:
                addVisitedStall()
            case .foodTasting:
                addVisitedStall() // This will automatically add dishes eaten
            case .budgetMaster:
                checkAndAddBudgetMeal()
            case .favoriteCollector:
                addFavoriteStall()
            case .areaSpecialist:
                if progress.areasExplored.count < 5 {
                    progress.areasExplored.append(UUID())
                }
            }
        }
        
        checkAndUpdateMilestones()
    }
    
    // Helper function to mark a stall as visited and its food as eaten
    private func addVisitedStall() {
        // Fetch available stalls
        let stallDescriptor = FetchDescriptor<Stalls>()
        
        do {
            let availableStalls = try modelContext.fetch(stallDescriptor)
            if !availableStalls.isEmpty {
                // Find a stall that hasn't been visited yet
                let alreadyVisitedStalls = Set(progress.stallsVisited)
                let newStalls = availableStalls.filter { !alreadyVisitedStalls.contains($0.id) }
                
                if let stallToVisit = newStalls.first {
                    // Add this stall to our visited stalls
                    progress.stallsVisited.append(stallToVisit.id)
                    
                    // Add all menu items from this stall to dishesEaten
                    for menuItem in stallToVisit.menu {
                        if !progress.dishesEaten.contains(menuItem.id) {
                            progress.dishesEaten.append(menuItem.id)
                        }
                    }
                    
                    // If the stall is budget-friendly, add it to budget meals
                    if stallToVisit.minimumPrice < 10000.0 {
                        progress.budgetMealsFound += 1
                        if progress.budgetStallsFound == nil {
                            progress.budgetStallsFound = []
                        }
                        progress.budgetStallsFound?.append(stallToVisit.id)
                    }
                    
                    // Update the area exploration if needed
                    if let area = stallToVisit.area, !progress.areasExplored.contains(area.id) {
                        progress.areasExplored.append(area.id)
                    }
                    
                } else if !availableStalls.isEmpty {
                    // If all stalls are visited, pick a random one for testing
                    let randomStall = availableStalls.randomElement()!
                    progress.stallsVisited.append(randomStall.id)
                }
            } else {
                // Fallback for testing if no stalls exist
                progress.stallsVisited.append(UUID())
            }
        } catch {
            print("Error fetching stalls: \(error)")
            // Fallback for testing
            progress.stallsVisited.append(UUID())
        }
    }
    
    // Helper function for adding favorite stalls
    private func addFavoriteStall() {
        // Fetch available stalls
        let stallDescriptor = FetchDescriptor<Stalls>(
            predicate: #Predicate<Stalls> { stall in
                !stall.isFavorite
            }
        )
        
        do {
            let availableStalls = try modelContext.fetch(stallDescriptor)
            if !availableStalls.isEmpty {
                // Find a stall to favorite
                if let stallToFavorite = availableStalls.first {
                    stallToFavorite.isFavorite = true
                    progress.favoritesCount += 1
                }
            } else {
                // For testing, just increment the count
                progress.favoritesCount += 1
            }
        } catch {
            print("Error fetching stalls for favorites: \(error)")
            // Fallback for testing
            progress.favoritesCount += 1
        }
    }
    
    // Helper function to find and add a budget meal
    private func checkAndAddBudgetMeal() {
        let budgetThreshold = 10000.0
        
        // Fetch stalls with minimum price under threshold
        let descriptor = FetchDescriptor<Stalls>(
            predicate: #Predicate<Stalls> { stall in
                stall.minimumPrice < budgetThreshold
            }
        )
        
        do {
            let affordableStalls = try modelContext.fetch(descriptor)
            if !affordableStalls.isEmpty {
                // Find a stall that hasn't been counted yet
                let alreadyCountedStalls = Set(progress.budgetStallsFound ?? [])
                let newAffordableStalls = affordableStalls.filter { !alreadyCountedStalls.contains($0.id) }
                
                if let stallToAdd = newAffordableStalls.first {
                    // Add this stall to our tracked budget stalls
                    if progress.budgetStallsFound == nil {
                        progress.budgetStallsFound = []
                    }
                    progress.budgetStallsFound?.append(stallToAdd.id)
                    progress.budgetMealsFound += 1
                } else {
                    // For demo purposes, increment anyway if all affordable stalls already counted
                    progress.budgetMealsFound += 1
                }
            } else {
                // Fallback for testing if no affordable stalls exist
                progress.budgetMealsFound += 1
            }
        } catch {
            print("Error fetching affordable stalls: \(error)")
            // Fallback increment for testing
            progress.budgetMealsFound += 1
        }
    }
    
    private func resetProgress() {
        progress.totalPoints = 0
        progress.currentRank = .newbie
        progress.stallsVisited = []
        progress.areasExplored = []
        progress.dishesEaten = []
        progress.budgetMealsFound = 0
        progress.budgetStallsFound = []
        progress.favoritesCount = 0
        progress.reviewsSubmitted = 0
        progress.completedQuests = []
        
        // Reset all milestone completion statuses
        for quest in quests {
            for milestone in quest.milestones {
                milestone.completed = false
            }
        }
        
        try? modelContext.save()
    }
}

struct EmptyStateView: View { let message: String
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text(message)
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

