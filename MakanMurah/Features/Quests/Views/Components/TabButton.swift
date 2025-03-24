//
//  TabButton.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 25/03/25.
//

import Foundation
import SwiftUI

struct TabButton: View {
    let title: String
    let isSelected: Bool
    var namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .padding(.horizontal, 4)
                
                if isSelected {
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(height: 3)
                        .cornerRadius(1.5)
                        .matchedGeometryEffect(id: "underline", in: namespace)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 3)
                }
            }
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

