//
//  Item.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 19/03/25.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class GOPArea {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var location2DLatitude: Double
    var location2DLongitude: Double

    init(
        name: String,
        location2DLatitude: Double,
        location2DLongitude: Double,
        id: UUID = UUID()
    ) {
        self.name = name
        self.location2DLatitude = location2DLatitude
        self.location2DLongitude = location2DLongitude
        self.id = id
    }

    var location2D: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(
                latitude: location2DLatitude,
                longitude: location2DLongitude
            )
        }
        set {
            location2DLatitude = newValue.latitude
            location2DLongitude = newValue.longitude
        }
    }
}

extension GOPArea {
    static let gop1 = GOPArea(
        name: "GOP 1",
        location2DLatitude: 37.33182,
        location2DLongitude: -122.03118
    )
    static let gop2 = GOPArea(
        name: "GOP 2",
        location2DLatitude: 37.77180,
        location2DLongitude: -122.46813
    )
    static let gop3 = GOPArea(
        name: "GOP 3",
        location2DLatitude: 34.05223,
        location2DLongitude: -118.24368
    )
    static let gop4 = GOPArea(
        name: "GOP 4",
        location2DLatitude: 40.71278,
        location2DLongitude: -74.00594
    )
    static let gop5 = GOPArea(
        name: "GOP 5",
        location2DLatitude: 47.60621,
        location2DLongitude: -122.33207
    )

    static let all: [GOPArea] = [gop1, gop2, gop3, gop4, gop5]
}

@Model
final class Stalls {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var desc: String
    var minimumPrice: Double
    var maximumPrice: Double
    var averagePrice: Double
    @Relationship var area: GOPArea?
    @Relationship(deleteRule: .cascade) var menu: [Menu] = []
    var isFavorite: Bool = false
    var image: Data?

    init(
        name: String,
        desc: String,
        minimumPrice: Double,
        maximumPrice: Double,
        averagePrice: Double,
        area: GOPArea? = nil,
        menu: [Menu] = [],
        isFavorite: Bool = false,
        image: Data? = nil,
        id: UUID = UUID()
    ) {
        self.id = id
        self.name = name
        self.desc = desc
        self.minimumPrice = minimumPrice
        self.maximumPrice = maximumPrice
        self.averagePrice = averagePrice
        self.area = area
        self.menu = menu
        self.isFavorite = isFavorite
        self.image = image
    }
}
