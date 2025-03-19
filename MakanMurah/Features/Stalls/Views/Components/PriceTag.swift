//
//  PriceTag.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 20/03/25.
//

import SwiftUI

struct PriceTag: View {
    let label: String
    let price: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("$\(price, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .frame(minWidth: 70)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

