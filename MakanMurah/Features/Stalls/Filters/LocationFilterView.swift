//
//  LocationFilterView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 20/03/25.
//

import SwiftUI
import SwiftData

struct LocationFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedArea: String?
    
    @Query private var areas: [GOPArea]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(areas) { area in
                    HStack {
                        Text(area.name)
                        Spacer()
                        if selectedArea == area.name {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedArea = area.name
                        dismiss()
                    }
                }
                
                HStack {
                    Text("All Locations")
                    Spacer()
                    if selectedArea == nil {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedArea = nil
                    dismiss()
                }
            }
            .navigationTitle("Location")
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

