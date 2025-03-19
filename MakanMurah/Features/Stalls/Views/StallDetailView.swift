//
//  StallDetailView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 20/03/25.
//

import SwiftUI

struct StallDetailView: View {
    let stall: Stalls
    @State private var isFavorite: Bool
    
    init(stall: Stalls) {
        self.stall = stall
        self._isFavorite = State(initialValue: stall.isFavorite)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header image
                if let imageData = stall.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 250)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundStyle(.gray)
                        }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Stall info section
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(stall.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if let area = stall.area {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundStyle(.red)
                                    Text(area.name)
                                        .font(.subheadline)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            isFavorite.toggle()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundStyle(isFavorite ? .red : .gray)
                                .frame(width: 44, height: 44)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                    
                    // Price info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Price Information")
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            PriceTag(label: "Min", price: stall.minimumPrice, color: .green)
                            PriceTag(label: "Avg", price: stall.averagePrice, color: .blue)
                            PriceTag(label: "Max", price: stall.maximumPrice, color: .orange)
                        }
                    }
                    
                    Divider()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        
                        Text(stall.desc)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    // Menu section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Menu")
                            .font(.headline)
                        
                        if stall.menu.isEmpty {
                            Text("No items available")
                                .italic()
                                .foregroundStyle(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ForEach(stall.menu) { item in
                                MenuItemRow(item: item)
                                
                                if item.id != stall.menu.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(stall.name)
                    .font(.headline)
            }
        }
    }
}

