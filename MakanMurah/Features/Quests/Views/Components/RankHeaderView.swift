//
//  RankHeaderView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 21/03/25.
//

import SwiftUI

struct RankHeaderView: View {
    var progress: UserProgress
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                // Rank display
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Rank")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(progress.currentRank.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if progress.currentRank != Rank.allCases.last {
                        let pointsNeeded = nextRank.pointsRequired - progress.totalPoints
                        Text("\(pointsNeeded) points to next rank")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Maximum rank achieved!")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 90, height: 90)
                    
                    Circle()
                        .trim(from: 0, to: progressPercentage)
                        .stroke(rankColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Image(systemName: progress.currentRank.icon)
                            .font(.system(size: 20))
                            .foregroundColor(rankColor)
                        
                        Text("\(progress.totalPoints)")
                            .font(.system(size: 16, weight: .bold))
                        
                        Text("points")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Progress bar to next rank
            if progress.currentRank != Rank.allCases.last {
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .foregroundColor(rankColor)
                                .frame(width: geometry.size.width * progressPercentage, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text("\(progress.currentRank.rawValue)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(nextRank.rawValue)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding()
    }
    
    private var nextRank: Rank {
        let currentIndex = Rank.allCases.firstIndex(of: progress.currentRank) ?? 0
        let nextIndex = min(currentIndex + 1, Rank.allCases.count - 1)
        return Rank.allCases[nextIndex]
    }
    
    private var progressPercentage: Double {
        if progress.currentRank == Rank.allCases.last {
            return 1.0
        }
        
        let currentPoints = Double(progress.totalPoints)
        let currentThreshold = Double(progress.currentRank.pointsRequired)
        let nextThreshold = Double(nextRank.pointsRequired)
        
        if nextThreshold <= currentThreshold {
            return 1.0
        }
        
        let percentage = (currentPoints - currentThreshold) / (nextThreshold - currentThreshold)
        return min(max(percentage, 0.0), 1.0)
    }
    
    private var rankColor: Color {
        switch progress.currentRank {
        case .newbie: return .blue
        case .bronze: return .orange
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .purple
        }
    }
}


