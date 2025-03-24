import SwiftUI
import SwiftData
import CoreLocation

struct StallsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var stalls: [Stalls]
    @Query private var areas: [GOPArea]
    
    // Filter states
    @State private var selectedPriceRange: PriceRange?
    @State private var selectedArea: String?
    @State private var selectedFoodType: MenuType?
    @State private var showFavoritesOnly = false
    
    // Sort states - using separate booleans to allow multiple selections
    @State private var sortByNearest = false
    @State private var sortByCheapest = false
    
    @StateObject private var locationManager = LocationManager()
    
    // Modal states
    @State private var showMainFilterModal = false
    @State private var showPriceFilterModal = false
    @State private var showLocationFilterModal = false
    @State private var showCuisineFilterModal = false
    
    private var filteredStalls: [Stalls] {
        var result = stalls.filter { stall in
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
            
            // Favorites filter
            let favoriteMatches = !showFavoritesOnly || stall.isFavorite
            
            return areaMatches && priceMatches && foodTypeMatches && favoriteMatches
        }
        
        // Apply sorting - can apply multiple sorts
        if sortByNearest && sortByCheapest {
            // When both are selected, sort by distance first, then by price
            if let userLocation = locationManager.currentLocation {
                // First create a dictionary of stalls with their distances for efficiency
                var stallDistances: [UUID: Double] = [:]
                
                for stall in result {
                    if let distance = calculateDistance(from: userLocation, to: stall) {
                        stallDistances[stall.id] = distance
                    }
                }
                
                // Sort by both criteria - nearest with price as secondary sort
                result.sort { stallA, stallB in
                    let distanceA = stallDistances[stallA.id]
                    let distanceB = stallDistances[stallB.id]
                    
                    // If both distances are available, compare them
                    if let distanceA = distanceA, let distanceB = distanceB {
                        if abs(distanceA - distanceB) < 100 { // If within 100m of each other (similar distance)
                            // Use price as tiebreaker
                            return stallA.averagePrice < stallB.averagePrice
                        }
                        return distanceA < distanceB
                    }
                    
                    // Handle cases where distance isn't available
                    if distanceA != nil { return true }
                    if distanceB != nil { return false }
                    
                    // If neither has distance, fall back to price
                    return stallA.averagePrice < stallB.averagePrice
                }
            } else {
                // Fall back to price sorting if location isn't available
                result.sort { $0.averagePrice < $1.averagePrice }
            }
        } else if sortByNearest {
            // Sort by distance only
            if let userLocation = locationManager.currentLocation {
                result.sort { stallA, stallB in
                    let distanceA = calculateDistance(from: userLocation, to: stallA)
                    let distanceB = calculateDistance(from: userLocation, to: stallB)
                    
                    if distanceA == nil { return false }
                    if distanceB == nil { return true }
                    
                    return distanceA! < distanceB!
                }
            }
        } else if sortByCheapest {
            // Sort by price only
            result.sort { $0.averagePrice < $1.averagePrice }
        }
        
        return result
    }
    
    private func calculateDistance(from userLocation: CLLocation, to stall: Stalls) -> Double? {
        guard let stallArea = stall.area,
              let latitude = stallArea.latitude,
              let longitude = stallArea.longitude else {
            return nil
        }
        
        let stallLocation = CLLocation(latitude: latitude, longitude: longitude)
        return userLocation.distance(from: stallLocation)
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
                        
                        // Sort by cheapest toggle pill
                        FilterPillButton(
                            title: "Cheapest",
                            isActive: sortByCheapest
                        ) {
                            sortByCheapest.toggle()
                        }
                        
                        // Sort by nearest toggle pill
                        FilterPillButton(
                            title: "Nearest",
                            isActive: sortByNearest
                        ) {
                            sortByNearest.toggle()
                            if sortByNearest {
                                locationManager.startUpdatingLocation()
                            }
                        }
                        
                        // Cuisine filter pill
                        FilterPillButton(
                            title: selectedFoodType == nil ? "Cuisine" : "Cuisine: \(selectedFoodType!.rawValue)",
                            isActive: selectedFoodType != nil
                        ) {
                            showCuisineFilterModal = true
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
                        
                        // Favorites filter toggle pill
                        FilterPillButton(
                            title: "Favorites",
                            isActive: showFavoritesOnly
                        ) {
                            showFavoritesOnly.toggle()
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
                    selectedFoodType: $selectedFoodType,
                    showFavoritesOnly: $showFavoritesOnly,
                    sortByNearest: $sortByNearest,
                    sortByCheapest: $sortByCheapest
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
        .onAppear {
            // Request location permissions when view appears (for nearest sort)
            if sortByNearest {
                locationManager.startUpdatingLocation()
            }
        }
    }
}
