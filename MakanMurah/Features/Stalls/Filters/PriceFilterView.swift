//
//  PriceFilterView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 20/03/25.
//

import SwiftUI

struct PriceFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPriceRange: PriceRange?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(PriceRange.allCases) { range in
                    HStack {
                        Text(range.displayName)
                        Spacer()
                        if selectedPriceRange == range {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPriceRange = range
                        dismiss()
                    }
                }
                
                HStack {
                    Text("All Prices")
                    Spacer()
                    if selectedPriceRange == nil {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedPriceRange = nil
                    dismiss()
                }
            }
            .navigationTitle("Price Range")
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
