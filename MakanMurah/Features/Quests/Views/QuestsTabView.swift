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
                        Button("Add Test Progress", action: addTestProgress)
                        Button("Reset Progress", action: resetProgress)
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
            progress.stallsVisited.append(UUID())
            progress.dishesEaten.append(UUID())
        } else {
            // Get the selected quest type with adjusted index
            let questTypeIndex = selectedTab - 1
            let selectedQuestType = QuestType.allCases[questTypeIndex]
            
            switch selectedQuestType {
            case .exploration:
                if progress.stallsVisited.count < 10 {
                    progress.stallsVisited.append(UUID())
                }
            case .foodTasting:
                if progress.dishesEaten.count < 20 {
                    progress.dishesEaten.append(UUID())
                }
            case .budgetMaster:
                progress.budgetMealsFound += 1
            case .foodCritic:
                progress.reviewsSubmitted += 1
            case .areaSpecialist:
                if progress.areasExplored.count < 5 {
                    progress.areasExplored.append(UUID())
                }
            }
        }
        
        checkAndUpdateMilestones()
    }
    
    private func resetProgress() {
        progress.totalPoints = 0
        progress.currentRank = .newbie
        progress.stallsVisited = []
        progress.areasExplored = []
        progress.dishesEaten = []
        progress.budgetMealsFound = 0
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

struct EmptyStateView: View {
    let message: String
    
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

// Extension to add a preview provider
struct QuestsTabView_Previews: PreviewProvider {
    static var previews: some View {
        QuestsTabView()
            .modelContainer(for: [Quest.self, Milestone.self, UserProgress.self], inMemory: true)
    }
}
