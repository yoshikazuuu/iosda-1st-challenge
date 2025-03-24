////
////  MenuRatingView.swift
////  MakanMurah
////
////  Created by Jerry Febriano on 21/03/25.
////
//
//import SwiftUI
//import SwiftData
//
//struct MenuRatingView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var userProgress: [UserProgress]
//    
//    var menu: Menu
//    @State private var userRating: Int = 0
//    @State private var reviewText: String = ""
//    @State private var showingCompletionAlert = false
//    
//    // Get or create user progress
//    private var progress: UserProgress {
//        if userProgress.isEmpty {
//            let newProgress = UserProgress()
//            modelContext.insert(newProgress)
//            return newProgress
//        }
//        return userProgress[0]
//    }
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Rate \(menu.name)")
//                .font(.title)
//                .bold()
//            
//            // Star rating
//            HStack {
//                ForEach(1...5, id: \.self) { star in
//                    Image(systemName: star <= userRating ? "star.fill" : "star")
//                        .font(.title)
//                        .foregroundColor(star <= userRating ? .yellow : .gray)
//                        .onTapGesture {
//                            userRating = star
//                        }
//                }
//            }
//            .padding()
//            
//            // Review text
//            VStack(alignment: .leading) {
//                Text("Your Review")
//                    .font(.headline)
//                
//                TextEditor(text: $reviewText)
//                    .frame(height: 120)
//                    .padding(4)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                    )
//                    .padding(.bottom)
//            }
//            
//            Button {
//                submitReview()
//            } label: {
//                Text("Submit Review")
//                    .font(.headline)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(userRating > 0 ? Color.blue : Color.gray)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//            .disabled(userRating == 0)
//        }
//        .padding()
//        .alert("Review Submitted!", isPresented: $showingCompletionAlert) {
//            Button("OK", role: .cancel) {
//                // You could dismiss the view here if showing as a sheet
//            }
//        } message: {
//            Text("Thank you for your review. You've earned points toward the Food Critic quest!")
//        }
//    }
//    
//    private func submitReview() {
//        guard userRating > 0 else { return }
//        
//        // Track the review submission for food critic quests
//        progress.reviewsSubmitted += 1
//        
//        // Find and complete any food critic jobs related to this menu
//        let descriptor = FetchDescriptor<QuestJob>(
//            predicate: #Predicate { job in
//                job.targetMenu?.id == menu.id &&
//                job.requiresRating &&
//                !job.isCompleted
//            }
//        )
//        
//        if let ratingJobs = try? modelContext.fetch(descriptor) {
//            for job in ratingJobs {
//                completeQuestJob(job)
//            }
//        }
//        
//        checkAndUpdateMilestones()
//        try? modelContext.save()
//        
//        showingCompletionAlert = true
//    }
//    
//    private func completeQuestJob(_ job: QuestJob) {
//        job.completeJob()
//        progress.completedJobs.append(job.id)
//        
//        // Also mark as tasted if it's required
//        if job.requiresTasting {
//            progress.recordDishTasted(menu)
//        }
//        
//        // Check if quest is complete
//        if let quest = job.quest {
//            let completedJobsForQuest = progress.completedJobs.filter { jobId in
//                quest.jobs.contains { $0.id == jobId }
//            }
//            
//            if completedJobsForQuest.count >= quest.requiredCount && !progress.completedQuests.contains(quest.id) {
//                // Complete quest
//                progress.completedQuests.append(quest.id)
//                progress.totalPoints += quest.reward
//                
//                // Update rank if needed
//                updateRank()
//            }
//        }
//    }
//    
//    private func updateRank() {
//        for rank in Rank.allCases.reversed() {
//            if progress.totalPoints >= rank.pointsRequired {
//                if progress.currentRank != rank {
//                    progress.currentRank = rank
//                }
//                break
//            }
//        }
//    }
//    
//    private func checkAndUpdateMilestones() {
//        var totalReward = 0
//        
//        // Fetch all quests
//        let descriptor = FetchDescriptor<Quest>()
//        if let quests = try? modelContext.fetch(descriptor) {
//            for quest in quests {
//                let currentProgress = progress.progressForQuest(questType: quest.type)
//                
//                // Find all eligible milestones
//                for milestone in quest.milestones where !milestone.completed && currentProgress >= milestone.threshold {
//                    milestone.completed = true
//                    progress.totalPoints += milestone.reward
//                    totalReward += milestone.reward
//                }
//            }
//        }
//        
//        if totalReward > 0 {
//            updateRank()
//        }
//    }
//}
