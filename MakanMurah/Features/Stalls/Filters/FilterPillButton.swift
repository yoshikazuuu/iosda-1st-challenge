//
//  FilterPillButton.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 20/03/25.
//

import SwiftUI

struct FilterPillButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .frame(height: 20)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isActive ? Color.blue.opacity(0.1) : Color(.systemGray6))
                .foregroundStyle(isActive ? .blue : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isActive ? Color.blue : Color.clear, lineWidth: 1)
                )
        }
    }
}

