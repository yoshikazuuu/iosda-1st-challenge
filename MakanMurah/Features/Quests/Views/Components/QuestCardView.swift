//
//  QuestCardView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 21/03/25.
//

import SwiftUI

struct QuestCardView: View {
    var quest: Quest
    var progress: UserProgress
    var onComplete: () -> Void
    
    private var completionPercentage: Double {
        let currentProgress = Double(progress.progressForQuest(questType: quest.type))
        return min(currentProgress / Double(quest.requiredCount), 1.0)
    }
    
    private var isCompleted: Bool {
        return progress.completedQuests.contains(quest.id)
    }
    
    private var sortedMilestones: [Milestone] {
        quest.milestones.sorted { $0.threshold < $1.threshold }
    }
    
    private var currentProgress: Int {
        progress.progressForQuest(questType: quest.type)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with quest title and progress
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(quest.type.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(typeColor.opacity(0.1))
                            .foregroundColor(typeColor)
                            .cornerRadius(4)
                        
                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    
                    Text(quest.title)
                        .font(.headline)
                }
                
                Spacer()
                
                Text("\(currentProgress)/\(quest.requiredCount)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Quest description
            Text(quest.desc)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isCompleted ? Color.green : typeColor)
                        .frame(width: geometry.size.width * completionPercentage, height: 8)
                }
            }
            .frame(height: 8)
            
            // Milestones
            if !sortedMilestones.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Milestones")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    
                    VStack(spacing: 8) {
                        ForEach(sortedMilestones) { milestone in
                            MilestoneView(
                                milestone: milestone,
                                currentProgress: currentProgress,
                                isQuestCompleted: isCompleted
                            )
                        }
                    }
                }
            }
            
            // Complete button or completed status
            if isCompleted {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text("Completed! +\(quest.reward) points")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            } else if completionPercentage >= 1.0 {
                Button(action: onComplete) {
                    HStack {
                        Image(systemName: "flag.checkered")
                        Text("Complete Quest")
                        Text("+\(quest.reward)").bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(typeColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var typeColor: Color {
        switch quest.type {
        case .exploration: return .blue
        case .foodTasting: return .orange
        case .budgetMaster: return .green
        case .favoriteCollector: return .purple
        case .areaSpecialist: return .indigo
        }
    }
}
