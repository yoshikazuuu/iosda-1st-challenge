//
//  StallDetailView.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 20/03/25.
//

import SwiftUI
import SwiftData
import CoreLocation
import MapKit

struct StallDetailView: View {
    let stall: Stalls
    @State private var isFavorite: Bool
    @State private var isVisited: Bool = false
    @State private var showingVisitedToast: Bool = false
    @StateObject private var locationManager = LocationManager()
    @State private var distance: String?
    @State private var showingLocationPermissionAlert = false
    
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgress: [UserProgress]
    
    private var progress: UserProgress {
        if userProgress.isEmpty {
            let newProgress = UserProgress()
            modelContext.insert(newProgress)
            return newProgress
        }
        return userProgress[0]
    }
    
    init(stall: Stalls) {
        self.stall = stall
        self._isFavorite = State(initialValue: stall.isFavorite)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header image
                if let imageData = stall.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 250)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundStyle(.gray)
                        }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Stall info section
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(stall.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if let area = stall.area {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundStyle(.red)
                                    Text(area.name)
                                        .font(.subheadline)
                                }
                                
                                // Show area coordinates for debugging
                                if let latitude = area.latitude, let longitude = area.longitude {
                                    Text("(\(latitude), \(longitude))")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                } else {
                                    Text("(No coordinates)")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            // Distance indicator
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(.orange)
                                
                                switch locationManager.authorizationStatus {
                                case .denied, .restricted:
                                    Button("Enable location") {
                                        showingLocationPermissionAlert = true
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                case .notDetermined:
                                    Text("Waiting for permission...")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                default:
                                    if let distance = distance {
                                        Text(distance)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    } else if getStallLocation() == nil {
                                        Text("Location not available")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    } else {
                                        Text("Calculating...")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            
                            // Visited indicator
                            if isVisited {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text("Visited")
                                        .font(.subheadline)
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            toggleFavorite()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundStyle(isFavorite ? .red : .gray)
                                .frame(width: 44, height: 44)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                    
                    // Rest of the view...
                    // (keeping the same as before)
                    
                    // Price info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Price")
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            PriceTag(label: "Min", price: stall.minimumPrice, color: .green)
                            PriceTag(label: "Avg", price: stall.averagePrice, color: .blue)
                            PriceTag(label: "Max", price: stall.maximumPrice, color: .orange)
                        }
                    }
                    
                    Divider()
                    
                    // Mark as visited button
                    if !isVisited {
                        Button {
                            markAsVisited()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("Mark as Visited")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        
                        Text(stall.desc)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    // Menu section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Menu")
                            .font(.headline)
                        
                        if stall.menu.isEmpty {
                            Text("No items available")
                                .italic()
                                .foregroundStyle(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ForEach(stall.menu) { item in
                                MenuItemRow(item: item)
                                
                                if item.id != stall.menu.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(stall.name)
                    .font(.headline)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    openInMaps()
                } label: {
                    Label("Locate", systemImage: "map")
                }
                .disabled(getStallLocation() == nil)
            }
        }
        .overlay(
            VisitedToast()
                .opacity(showingVisitedToast ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: showingVisitedToast)
        )
        .onAppear {
            checkIfVisited()
            locationManager.startUpdatingLocation()
            calculateDistance()
        }
        .onChange(of: locationManager.currentLocation) { _, newLocation in
            if newLocation != nil {
                calculateDistance()
            }
        }
        .alert("Location Access Required", isPresented: $showingLocationPermissionAlert) {
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable location access in Settings to see the distance to this stall.")
        }
    }
    
    private func getStallLocation() -> CLLocation? {
        guard let area = stall.area,
              let latitude = area.latitude,
              let longitude = area.longitude else {
            return nil
        }
        
        // Ensure the coordinates are valid
        guard CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) else {
            return nil
        }
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Other methods remain the same
    private func calculateDistance() {
        guard let userLocation = locationManager.currentLocation else {
            distance = "Waiting for location"
            return
        }
        
        guard let stallLocation = getStallLocation() else {
            distance = "No stall location"
            return
        }
        
        let distanceInMeters = userLocation.distance(from: stallLocation)
        
        if distanceInMeters < 1000 {
            distance = "\(Int(distanceInMeters))m away"
        } else {
            let distanceInKm = distanceInMeters / 1000
            distance = String(format: "%.1f km away", distanceInKm)
        }
    }

    
    private func checkIfVisited() {
        isVisited = progress.stallsVisited.contains(stall.id)
    }
    
    private func markAsVisited() {
        // Add stall ID to visited stalls if not already there
        if !progress.stallsVisited.contains(stall.id) {
            progress.stallsVisited.append(stall.id)
            isVisited = true
            
            // Show toast notification
            showingVisitedToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showingVisitedToast = false
            }
            
            // Check and update any quests related to stall visits
            checkAndUpdateQuestProgress()
            
            try? modelContext.save()
        }
    }
    
    private func toggleFavorite() {
        isFavorite.toggle()
        stall.isFavorite = isFavorite
        
        // Update favorite count in user progress if needed
        if isFavorite && !progress.completedQuests.contains(where: { $0 == stall.id }) {
            progress.favoritesCount += 1
        } else if !isFavorite {
            progress.favoritesCount = max(0, progress.favoritesCount - 1)
        }
        
        try? modelContext.save()
    }
    
    private func openInMaps() {
        guard let area = stall.area,
              let latitude = area.latitude,
              let longitude = area.longitude else {
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = stall.name
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    private func checkAndUpdateQuestProgress() {
        // Update quest progress
        // For exploration quests
        if let area = stall.area, !progress.areasExplored.contains(area.id) {
            progress.areasExplored.append(area.id)
        }
        
        try? modelContext.save()
    }
}

// Toast notification for when a stall is marked as visited
struct VisitedToast: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Marked as visited!")
                    .fontWeight(.medium)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.bottom, 100)
        }
    }
}
