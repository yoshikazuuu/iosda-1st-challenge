//
//  StallEditView.swift
//  MakanMurah
//  Created by Jerry Febriano on 24/03/25.
//

import SwiftUI
import SwiftData

struct StallEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var stall: Stalls
    
    @Query private var areas: [GOPArea]
    
    @State private var name: String
    @State private var description: String
    @State private var minimumPrice: Double
    @State private var maximumPrice: Double
    @State private var selectedAreaIndex: Int?
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingAddMenuSheet = false
    @State private var menuToEdit: FoodMenu?
    
    // Track if changes have been made
    @State private var hasChanges = false
    @State private var showingDiscardAlert = false
    
    init(stall: Stalls) {
        self.stall = stall
        _name = State(initialValue: stall.name)
        _description = State(initialValue: stall.desc)
        _minimumPrice = State(initialValue: stall.minimumPrice)
        _maximumPrice = State(initialValue: stall.maximumPrice)
        
        // Initialize image if available
        if let imageData = stall.image {
            _selectedImage = State(initialValue: UIImage(data: imageData))
        }
        
        // Find the index of the stall's area in the areas array
        if let areaName = stall.area?.name {
            _selectedAreaIndex =
            State(initialValue: areas.firstIndex(where: { $0.name == areaName }))
        }
    }
    
    var body: some View {
        Form {
            // Basic Information
            Section(header: Text("Basic Information")) {
                TextField("Stall Name", text: $name)
                    .onChange(of: name) { _, _ in
                        hasChanges = true
                    }
                
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3 ... 6)
                    .onChange(of: description) { _, _ in
                        hasChanges = true
                    }
            }
            
            // Pricing Information
            Section(header: Text("Pricing")) {
                HStack {
                    Text("Minimum Price")
                    Spacer()
                    TextField(
                        "Minimum",
                        value: $minimumPrice,
                        format: .currency(code: "IDR")
                    )
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .onChange(of: minimumPrice) { _, _ in
                        hasChanges = true
                    }
                }
                
                HStack {
                    Text("Maximum Price")
                    Spacer()
                    TextField(
                        "Maximum",
                        value: $maximumPrice,
                        format: .currency(code: "IDR")
                    )
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .onChange(of: maximumPrice) { _, _ in
                        hasChanges = true
                    }
                }
            }
            
            // Location
            Section(header: Text("Location")) {
                Picker("Select Area", selection: $selectedAreaIndex) {
                    Text("None").tag(nil as Int?)
                    ForEach(Array(areas.enumerated()), id: \.offset) { index, area in
                        Text(area.name).tag(index as Int?)
                    }
                }
                .onChange(of: selectedAreaIndex) { _, _ in
                    hasChanges = true
                }
            }
            
            // Stall Image
            Section(header: Text("Stall Image")) {
                ZStack {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    } else if let imageData = stall.image,
                              let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 200)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("No Image Selected")
                                        .foregroundColor(.gray)
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                isShowingImagePicker = true
                                hasChanges = true
                            }) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Circle().fill(Color.blue))
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            .padding([.bottom], 10)
                            .padding([.bottom, .trailing], 10)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Menu Items Section
            // Menu Items Section
            Section(
                header: HStack {
                    Text("Menu Items")
                    Spacer()
                    Button(action: {
                        menuToEdit = nil
                        showingAddMenuSheet = true
                    }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                    }
                }
            ) {
                if stall.menu.isEmpty {
                    ContentUnavailableView {
                        Label("No Menu Items", systemImage: "fork.knife")
                    } description: {
                        Text("Add menu items to this stall.")
                    }
                } else {
                    ForEach(stall.menu) { menuItem in
                        HStack {
                            if let imageData = menuItem.image,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            } else {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "fork.knife")
                                            .foregroundColor(.gray)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(menuItem.name)
                                    .font(.headline)
                                Text("\(menuItem.price, format: .currency(code: "IDR"))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 8)
                        }
                        .contextMenu {
                            Button {
                                menuToEdit = menuItem
                                showingAddMenuSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                deleteMenuItem(menuItem)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteMenuItem(menuItem)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                menuToEdit = menuItem
                                showingAddMenuSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
            
            Section {
                Button(action: {
                    saveChanges()
                }) {
                    Text("Save Changes")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!hasChanges && menuToEdit == nil)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Edit \(stall.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveChanges()
                }
                .disabled(!hasChanges && menuToEdit == nil)
            }
            
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button("Cancel") {
//                    if hasChanges {
//                        showingDiscardAlert = true
//                    } else {
//                        dismiss()
//                    }
//                }
//            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .sheet(isPresented: $showingAddMenuSheet) {
            MenuFormView(stall: stall, menuToEdit: menuToEdit)
        }
        .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Discard", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("You have unsaved changes. Are you sure you want to discard them?")
        }
    }
    
    private func saveChanges() {
        stall.name = name
        stall.desc = description
        stall.minimumPrice = minimumPrice
        stall.maximumPrice = maximumPrice
        
        // Update average price
        stall.averagePrice = (minimumPrice + maximumPrice) / 2
        
        // Update area
        if let selectedIndex = selectedAreaIndex {
            stall.area = areas[selectedIndex]
        } else {
            stall.area = nil
        }
        
        // Update image
        if let selectedImage = selectedImage {
            stall.image = selectedImage.jpegData(compressionQuality: 0.8)
        }
        
        try? modelContext.save()
        hasChanges = false
        dismiss()
    }
    
    private func deleteMenuItem(_ menuItem: FoodMenu) {
        stall.menu.removeAll { $0.id == menuItem.id }
        modelContext.delete(menuItem)
        try? modelContext.save()
    }
}
