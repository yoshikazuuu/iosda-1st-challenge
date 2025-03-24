//
//  StallsTabView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 20/03/25.
//

import SwiftUI
import SwiftData

struct StallsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var stalls: [Stalls]
    @Query private var areas: [GOPArea]
    
    // Filter states
    @State private var selectedPriceRange: PriceRange?
    @State private var selectedArea: String?
    @State private var selectedFoodType: MenuType?
    
    // Modal states
    @State private var showMainFilterModal = false
    @State private var showPriceFilterModal = false
    @State private var showLocationFilterModal = false
    @State private var showCuisineFilterModal = false
    
    private var filteredStalls: [Stalls] {
        stalls.filter { stall in
            // Area filter
            let areaMatches = selectedArea == nil || stall.area?.name == selectedArea
            
            // Price range filter
            let priceMatches: Bool
            if let range = selectedPriceRange {
                priceMatches = stall.averagePrice >= range.min && stall.averagePrice <= range.max
            } else {
                priceMatches = true
            }
            
            // Food type filter
            let foodTypeMatches: Bool
            if let foodType = selectedFoodType {
                foodTypeMatches = stall.menu.contains { $0.menuType == foodType }
            } else {
                foodTypeMatches = true
            }
            
            return areaMatches && priceMatches && foodTypeMatches
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Filter pills row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // Main filter button
                        Button {
                            showMainFilterModal = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "line.3.horizontal.decrease")
                            }
                            .font(.headline)
                            .frame(height: 20)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                        }
                        
                        // Price filter pill
                        FilterPillButton(
                            title: selectedPriceRange == nil ? "Price" : "Price: \(selectedPriceRange!.displayName)",
                            isActive: selectedPriceRange != nil
                        ) {
                            showPriceFilterModal = true
                        }
                        
                        // Location filter pill
                        FilterPillButton(
                            title: selectedArea == nil ? "Location" : "Location: \(selectedArea!)",
                            isActive: selectedArea != nil
                        ) {
                            showLocationFilterModal = true
                        }
                        
                        // Cuisine filter pill
                        FilterPillButton(
                            title: selectedFoodType == nil ? "Cuisine" : "Cuisine: \(selectedFoodType!.rawValue)",
                            isActive: selectedFoodType != nil
                        ) {
                            showCuisineFilterModal = true
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
                
                // Stalls grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(filteredStalls) { stall in
                            NavigationLink(destination: StallDetailView(stall: stall)) {
                                StallCard(stall: stall)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(16)
                }
            }
            .navigationBarTitleDisplayMode(.automatic)
            .navigationTitle("Food Stalls")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        NavigationLink(destination: StallFormView()) {
                            Label("Add New Stall", systemImage: "plus")
                        }
                        
                        if !filteredStalls.isEmpty {
                            Divider()
                            
                            NavigationLink(destination: StallsManagementView(stalls: stalls)) {
                                Label("Manage Stalls", systemImage: "list.bullet.rectangle")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }

            
            // Main filter modal
            .sheet(isPresented: $showMainFilterModal) {
                MainFilterView(
                    selectedPriceRange: $selectedPriceRange,
                    selectedArea: $selectedArea,
                    selectedFoodType: $selectedFoodType
                )
            }
            
            // Individual filter modals
            .sheet(isPresented: $showPriceFilterModal) {
                PriceFilterView(selectedPriceRange: $selectedPriceRange)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showLocationFilterModal) {
                LocationFilterView(selectedArea: $selectedArea)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showCuisineFilterModal) {
                CuisineFilterView(selectedFoodType: $selectedFoodType)
                    .presentationDetents([.medium])
            }
        }
    }
    
    func placeOrder() { }
    func adjustOrder() { }
    func cancelOrder() { }
}

#Preview {
    StallsTabView()
}
