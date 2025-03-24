import SwiftUI
import SwiftData

struct MainFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPriceRange: PriceRange?
    @Binding var selectedArea: String?
    @Binding var selectedFoodType: MenuType?
    @Binding var showFavoritesOnly: Bool
    @Binding var sortByNearest: Bool
    @Binding var sortByCheapest: Bool
    
    @Query private var areas: [GOPArea]
    
    var body: some View {
        NavigationStack {
            Form {
                // Favorites filter
                Section("Show Only") {
                    Toggle("Favorites", isOn: $showFavoritesOnly)
                }
                
                // Sort options
                Section("Sort By") {
                    Toggle("Nearest", isOn: $sortByNearest)
                    Toggle("Cheapest", isOn: $sortByCheapest)
                }
                
                // Price range section
                Section("Price Range") {
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
                    }
                }
                
                // Location section
                Section("Location") {
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
                    }
                }
                
                // Cuisine section
                Section("Cuisine") {
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
                    }
                }
                
                Section {
                    Button("Reset All Filters") {
                        selectedPriceRange = nil
                        selectedArea = nil
                        selectedFoodType = nil
                        showFavoritesOnly = false
                        sortByNearest = false
                        sortByCheapest = false
                    }
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Filter Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
