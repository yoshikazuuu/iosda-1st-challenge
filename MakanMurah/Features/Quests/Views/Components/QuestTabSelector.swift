//
//  QuestTabSelector.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 21/03/25.
//

import SwiftUI

struct QuestTabSelector: View {
    @Binding var selectedTab: Int
    let questTypes = QuestType.allCases
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                QuestTabButton(
                    title: "All Quests",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )
                ForEach(0..<questTypes.count, id: \.self) { index in
                    QuestTabButton(
                        title: questTypes[index].rawValue,
                        isSelected: selectedTab == index + 1,
                        action: { selectedTab = index + 1 }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
}
