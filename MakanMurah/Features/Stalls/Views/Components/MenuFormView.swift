//
//  MenuFormView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 24/03/25.
//

import SwiftUI

struct MenuFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var stall: Stalls
    var menuToEdit: FoodMenu?
    
    @State private var name: String = ""
    @State private var price: Double = 0
    @State private var description: String = ""
    @State private var menuType: MenuType = .indonesian
    @State private var types: [String] = []
    @State private var dietType: String = ""
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage?
    
    @State private var newType: String = ""
    @State private var newIngredient: String = ""
    
    init(stall: Stalls, menuToEdit: FoodMenu? = nil) {
        self.stall = stall
        self.menuToEdit = menuToEdit
        
        if let menu = menuToEdit {
            _name = State(initialValue: menu.name)
            _price = State(initialValue: menu.price)
            _description = State(initialValue: menu.desc)
            _menuType = State(initialValue: menu.menuType)
            _types = State(initialValue: menu.type)
            _dietType = State(initialValue: menu.dietType)
            
            if let imageData = menu.image {
                _selectedImage = State(initialValue: UIImage(data: imageData))
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic Information
                Section(header: Text("Basic Information")) {
                    TextField("Menu Name", text: $name)
                    
                    HStack {
                        Text("Price")
                        Spacer()
                        TextField("Price", value: $price, format: .currency(code: "IDR"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Cuisine Type", selection: $menuType) {
                        ForEach(MenuType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                // Description
                Section(header: Text("Description")) {
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Image Selection
                Section(header: Text("Menu Image")) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(8)
                            .padding(.vertical, 8)
                    }
                    
                    Button(action: {
                        isShowingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                                .imageScale(.large)
                            Text(selectedImage == nil ? "Select Image" : "Change Image")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                // Special Types
                Section(header: Text("Special Types")) {
                    ForEach(types, id: \.self) { type in
                        HStack {
                            Text(type)
                            Spacer()
                            Button {
                                types.removeAll { $0 == type }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("Add type (e.g., Spicy, Vegan)", text: $newType)
                        Button {
                            if !newType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                               !types.contains(newType) {
                                types.append(newType)
                                newType = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                        .disabled(newType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                
//                // Ingredients
//                Section(header: Text("Ingredients")) {
//                    ForEach(dietType, id: \.self) { ingredient in
//                        HStack {
//                            Text(dietType)
//                            Spacer()
//                            Button {
//                                dietType.removeAll { $0 == ingredient }
//                            } label: {
//                                Image(systemName: "minus.circle.fill")
//                                    .foregroundColor(.red)
//                            }
//                        }
//                    }
//                    
//                    HStack {
//                        TextField("Add ingredient", text: $newIngredient)
//                        Button {
//                            if !newIngredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
//                               !dietType.contains(newIngredient) {
//                                dietType.append(newIngredient)
//                                newIngredient = ""
//                            }
//                        } label: {
//                            Image(systemName: "plus.circle.fill")
//                                .foregroundColor(.green)
//                        }
//                        .disabled(newIngredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//                    }
//                }
                
                // Save Button
                Section {
                    Button(action: saveMenu) {
                        HStack {
                            Spacer()
                            Text(menuToEdit == nil ? "Add Menu Item" : "Update Menu Item")
                                .bold()
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle(menuToEdit == nil ? "Add Menu Item" : "Edit Menu Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMenu()
                    }
                    .disabled(!isFormValid)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        price > 0
    }
    
    private func saveMenu() {
        if !isFormValid {
            return
        }
        
        // If editing an existing menu
        if let existingMenu = menuToEdit {
            existingMenu.name = name
            existingMenu.price = price
            existingMenu.desc = description
            existingMenu.menuType = menuType
            existingMenu.type = types
            existingMenu.dietType = dietType
            
            if let selectedImage = selectedImage {
                existingMenu.image = selectedImage.jpegData(compressionQuality: 0.8)
            }
        } else {
            // Create new menu
            let newMenu = FoodMenu(
                name: name,
                price: price,
                desc: description,
                image: selectedImage?.jpegData(compressionQuality: 0.8),
                type: types,
                dietType: dietType,
                menuType: menuType,
                stalls: stall
            )
            
            // Add to stall's menu array
            stall.menu.append(newMenu)
            modelContext.insert(newMenu)
        }
        
        try? modelContext.save()
        dismiss()
    }
}
