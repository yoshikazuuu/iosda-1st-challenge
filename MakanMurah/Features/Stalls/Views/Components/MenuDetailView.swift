//
//  MenuDetailView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 24/03/25.
//

import SwiftUI

struct MenuDetailView: View {
    var menu: FoodMenu
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageData = menu.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 5)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(menu.name)
                        .font(.largeTitle)
                        .bold()
                    
                    Text("\(menu.price, format: .currency(code: "IDR"))")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text(menu.menuType.rawValue)
                        .font(.headline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(20)
                }
                
                Divider()
                
                Text("Description")
                    .font(.headline)
                
                Text(menu.desc)
                    .font(.body)
                
                if !menu.ingredients.isEmpty {
                    Divider()
                    
                    Text("Ingredients")
                        .font(.headline)
                    
                    ForEach(menu.ingredients, id: \.self) { ingredient in
                        HStack(alignment: .top) {
                            Text("•")
                            Text(ingredient)
                        }
                    }
                }
                
                if !menu.type.isEmpty {
                    Divider()
                    
                    Text("Special Attributes")
                        .font(.headline)
                    
                    HStack {
                        ForEach(menu.type, id: \.self) { attribute in
                            Text(attribute)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(16)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Menu Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
