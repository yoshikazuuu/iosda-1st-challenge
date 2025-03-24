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
final class Stalls {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var desc: String
    var minimumPrice: Double
    var maximumPrice: Double
    var averagePrice: Double
    @Relationship var area: GOPArea?
    @Relationship(deleteRule: .cascade) var menu: [FoodMenu] = []
    var isFavorite: Bool = false
    var image: Data?

    init(
        name: String,
        desc: String,
        minimumPrice: Double,
        maximumPrice: Double,
        averagePrice: Double,
        area: GOPArea? = nil,
        menu: [FoodMenu] = [],
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

extension Stalls {
    var latitude: Double? {
        get { area?.latitude }
        set { area?.latitude = newValue ?? 0 }
    }
    
    var longitude: Double? {
        get { area?.longitude }
        set { area?.longitude = newValue ?? 0 }
    }
}
