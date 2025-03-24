//
//  MilestoneView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 21/03/25.
//

import SwiftUI

struct MilestoneView: View {
    var milestone: Milestone
    var currentProgress: Int
    var isQuestCompleted: Bool
    
    private var isCompleted: Bool {
        milestone.completed || isQuestCompleted || currentProgress >= milestone.threshold
    }
    
    private var isNext: Bool {
        !isCompleted && currentProgress < milestone.threshold
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Status icon
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : (isNext ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2)))
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Milestone details
            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.title)
                    .font(.subheadline)
                    .foregroundColor(isCompleted ? .primary : (isNext ? .primary : .secondary))
                
                Text("\(milestone.threshold) required - \(milestone.reward) points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Reward indicator
            if isCompleted {
                Text("+\(milestone.reward)")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

