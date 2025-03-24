//
//  StallManagementView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 24/03/25.
//

import SwiftUI

struct StallsManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var stalls: [Stalls]
    @State private var showingDeleteAlert = false
    @State private var stallToDelete: Stalls?
    
    var body: some View {
        List {
            ForEach(stalls) { stall in
                NavigationLink(destination: StallEditView(stall: stall)) {
                    HStack {
                        if let imageData = stall.image, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "fork.knife")
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        VStack(alignment: .leading) {
                            Text(stall.name)
                                .font(.headline)
                            Text(stall.area?.name ?? "No location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 8)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        stallToDelete = stall
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    NavigationLink(destination: StallEditView(stall: stall)) {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .navigationTitle("Manage Stalls")
        .alert("Delete Stall", isPresented: $showingDeleteAlert, presenting: stallToDelete) { stall in
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteStall(stall)
            }
        } message: { stall in
            Text("Are you sure you want to delete \(stall.name)? This action cannot be undone.")
        }
    }
    
    private func deleteStall(_ stall: Stalls) {
        modelContext.delete(stall)
        do {
            try modelContext.save()
        } catch {
            print("Error deleting stall: \(error)")
        }
    }
}
