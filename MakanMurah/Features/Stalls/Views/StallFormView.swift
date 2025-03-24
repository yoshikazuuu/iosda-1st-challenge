//
//  StallFormView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 24/03/25.
//

import SwiftUI
import SwiftData

struct StallFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var areas: [GOPArea]
    
    // Form fields
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var minimumPrice: Double = 0
    @State private var maximumPrice: Double = 0
    @State private var selectedAreaIndex: Int?
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage?
    
    // Validation states
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic Information
                Section(header: Text("Basic Information")) {
                    TextField("Stall Name", text: $name)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Pricing Information
                Section(header: Text("Pricing")) {
                    HStack {
                        Text("Minimum Price")
                        Spacer()
                        TextField("Minimum", value: $minimumPrice, format: .currency(code: "IDR"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Maximum Price")
                        Spacer()
                        TextField("Maximum", value: $maximumPrice, format: .currency(code: "IDR"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Location
                Section(header: Text("Location")) {
                    Picker("Select Area", selection: $selectedAreaIndex) {
                        Text("Select a location").tag(nil as Int?)
                        ForEach(Array(areas.enumerated()), id: \.offset) { index, area in
                            Text(area.name).tag(index as Int?)
                        }
                    }
                }
                
                // Image Selection
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
                
                // Submit button
                Section {
                    Button(action: {
                        submitForm()
                    }) {
                        Text("Add Stall")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!isFormValid)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Add New Stall")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .alert("Validation Error", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        minimumPrice >= 0 &&
        maximumPrice >= minimumPrice &&
        selectedAreaIndex != nil
    }
    
    private func validateForm() -> Bool {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter a stall name."
            showingValidationAlert = true
            return false
        }
        
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter a stall description."
            showingValidationAlert = true
            return false
        }
        
        if minimumPrice < 0 {
            validationMessage = "Minimum price cannot be negative."
            showingValidationAlert = true
            return false
        }
        
        if maximumPrice < minimumPrice {
            validationMessage = "Maximum price must be greater than or equal to minimum price."
            showingValidationAlert = true
            return false
        }
        
        if selectedAreaIndex == nil {
            validationMessage = "Please select a location for the stall."
            showingValidationAlert = true
            return false
        }
        
        return true
    }
    
    private func submitForm() {
        if !validateForm() {
            return
        }
        
        // Calculate average price
        let averagePrice = (minimumPrice + maximumPrice) / 2
        
        // Create new stall
        let newStall = Stalls(
            name: name,
            desc: description,
            minimumPrice: minimumPrice,
            maximumPrice: maximumPrice,
            averagePrice: averagePrice,
            area: selectedAreaIndex != nil ? areas[selectedAreaIndex!] : nil,
            menu: [],
            isFavorite: false,
            image: selectedImage?.jpegData(compressionQuality: 0.8)
        )
        
        // Save to the database
        modelContext.insert(newStall)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving stall: \(error)")
            validationMessage = "Failed to save stall: \(error.localizedDescription)"
            showingValidationAlert = true
        }
    }
}

// Image Picker helper that uses UIKit's UIImagePickerController through UIViewControllerRepresentable
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// Preview provider
#Preview {
    StallFormView()
        .modelContainer(for: [Stalls.self, GOPArea.self, FoodMenu.self])
}

