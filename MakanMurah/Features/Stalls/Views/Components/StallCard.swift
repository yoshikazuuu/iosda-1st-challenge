//
//  StallCard.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 20/03/25.
//

import SwiftUI

struct StallCard: View {
    let stall: Stalls
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                if let imageData = stall.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 30))
                                .foregroundStyle(.gray)
                        }
                }
                
                if stall.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.white, .red)
                        .padding(8)
                        .shadow(radius: 2)
                }
            }
            
            Text(stall.name)
                .font(.headline)
                .lineLimit(1)
            
            HStack {
                Text(stall.area?.name ?? "Unknown")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
                
                Spacer()
                
                Text("$\(stall.averagePrice, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

