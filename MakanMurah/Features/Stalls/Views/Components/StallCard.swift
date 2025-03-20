//
//  StallCard.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 20/03/25.
//

import SwiftUI

struct StallCard: View {
    let stall: Stalls
    
    // Calculate the card width for a two-column grid.
    // Assuming horizontal padding of 20 on both sides and 16 spacing between columns.
    private let totalHorizontalPadding: CGFloat = 20 * 2
    private let interColumnSpacing: CGFloat = 16
    private var cardWidth: CGFloat {
        (UIScreen.main.bounds.width - totalHorizontalPadding - interColumnSpacing) / 2
    }
    
    private let imageHeight: CGFloat = 120
    
    var body: some View {
        VStack(spacing: 0) {
            // Image section with no padding so it fills the card edge-to-edge.
            ZStack(alignment: .topTrailing) {
                if let imageData = stall.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: cardWidth, height: imageHeight)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: cardWidth, height: imageHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
            
            // Text section with padding
            VStack(alignment: .leading, spacing: 6) {
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
        }
        .frame(width: cardWidth)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
