import Foundation
import SwiftData
import CoreLocation

@Model
final class GOPArea {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var latitude: Double?
    var longitude: Double?
    
    init(
        name: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        id: UUID = UUID()
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var location2D: CLLocationCoordinate2D? {
        get {
            guard let lat = latitude, let lon = longitude else {
                return nil
            }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }
}

// Extension with sample data
extension GOPArea {
    static let gop1 = GOPArea(name: "GOP 1", latitude: -6.2088, longitude: 106.8456)
    static let gop2 = GOPArea(name: "GOP 2", latitude: -6.2097, longitude: 106.8475)
    static let gop3 = GOPArea(name: "GOP 3", latitude: -6.2105, longitude: 106.8460)
    static let gop4 = GOPArea(name: "GOP 4", latitude: -6.2080, longitude: 106.8490)
    static let gop5 = GOPArea(name: "GOP 5", latitude: -6.2070, longitude: 106.8470)
    
    static let all: [GOPArea] = [gop1, gop2, gop3, gop4, gop5]
}
