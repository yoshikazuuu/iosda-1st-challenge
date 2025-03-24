//
//  StallCard.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 20/03/25.
//

import SwiftUI
import CoreLocation
import MapKit

struct StallCard: View {
    let stall: Stalls
    @StateObject private var locationManager = LocationManager()
    @State private var distance: String?
    
    // Calculate the card width for a two-column grid.
    private let totalHorizontalPadding: CGFloat = 20 * 2
    private let interColumnSpacing: CGFloat = 16
    private var cardWidth: CGFloat {
        (UIScreen.main.bounds.width - totalHorizontalPadding - interColumnSpacing) / 2
    }
    
    private let imageHeight: CGFloat = 120
    
    var body: some View {
        VStack(spacing: 0) {
            // Image section
            ZStack(alignment: .topTrailing) {
                if let imageData = stall.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: cardWidth, height: imageHeight)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: cardWidth, height: imageHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 30))
                                .foregroundStyle(.gray)
                        }
                }
                
                if stall.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                        .padding(8)
                        .shadow(radius: 2)
                }
            }
            
            // Text section with padding
            VStack(alignment: .leading, spacing: 6) {
                Text(stall.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(stall.area?.name ?? "Unknown")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Text("Rp\(stall.averagePrice, specifier: "%.0f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                }
                
                // Distance label
                HStack {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    if locationManager.authorizationStatus == .denied ||
                       locationManager.authorizationStatus == .restricted {
                        Text("Enable location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if let distance = distance {
                        Text(distance)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Calculating...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 2)
            }
            .padding(12)
        }
        .frame(width: cardWidth)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onAppear {
            print("📌 Stall location: \(stall.area?.latitude ?? 0), \(stall.area?.longitude ?? 0)")
            locationManager.startUpdatingLocation()
            calculateDistance()
        }
        .onChange(of: locationManager.currentLocation) { _, newLocation in
            if newLocation != nil {
                calculateDistance()
            }
        }
    }
    
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
    
    private func getStallLocation() -> CLLocation? {
        guard let area = stall.area,
              let latitude = area.latitude,
              let longitude = area.longitude else {
            print("⚠️ Missing location data for stall: \(stall.name)")
            return nil
        }
        
        // Ensure the coordinates are valid
        guard CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) else {
            print("⚠️ Invalid coordinates for stall: \(stall.name) - \(latitude), \(longitude)")
            return nil
        }
        
        print("📍 Stall location found: \(latitude), \(longitude)")
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
