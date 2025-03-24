//
//  LocationManager.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 25/03/25.
//

import SwiftUI
import CoreLocation
import MapKit

// Enhanced LocationManager with better status reporting
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.authorizationStatus = locationManager.authorizationStatus
        
        // Request permission right away
        self.requestLocationPermission()
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    // Handle authorization changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("📍 Location permission granted")
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            locationError = "Location access denied."
            print("📍 Location permission denied")
            currentLocation = nil
        case .notDetermined:
            locationError = "Location permission not determined."
            print("📍 Location permission not determined")
            currentLocation = nil
        @unknown default:
            locationError = "Unknown authorization status."
            print("📍 Unknown location permission status")
            currentLocation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("📍 Location error: \(error.localizedDescription)")
        locationError = error.localizedDescription
    }
}
