//
//  QuestsTabView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 20/03/25.
//

import SwiftUI

struct QuestsTabView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "map.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                    .padding()
                
                Text("Quests Feature Coming Soon")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Explore food adventures and complete culinary challenges around different areas.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Food Quests")
        }
    }
}

