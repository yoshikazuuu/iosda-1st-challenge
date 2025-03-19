//
//  CuisineFilterView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 20/03/25.
//

import SwiftUI

struct CuisineFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedFoodType: MenuType?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(MenuType.allCases, id: \.self) { type in
                    HStack {
                        Text(type.rawValue)
                        Spacer()
                        if selectedFoodType == type {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedFoodType = type
                        dismiss()
                    }
                }
                
                HStack {
                    Text("All Cuisines")
                    Spacer()
                    if selectedFoodType == nil {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedFoodType = nil
                    dismiss()
                }
            }
            .navigationTitle("Cuisine Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

