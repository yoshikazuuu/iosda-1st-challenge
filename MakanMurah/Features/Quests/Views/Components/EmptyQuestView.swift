//
//  EmptyQuestView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 21/03/25.
//

import SwiftUI

struct EmptyQuestView: View {
    var questType: QuestType
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "map")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.7))
            
            Text("No \(questType.rawValue) Quests")
                .font(.headline)
            
            Text("New quests will appear here soon!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

