//
//  Menu.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 19/03/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class FoodMenu {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var price: Double
    var desc: String
    var image: Data?
    var type: [String]
    var ingredients: [String]
    var menuType: MenuType

    @Relationship var stalls: Stalls?

    init(
        name: String,
        price: Double,
        desc: String,
        image: Data? = nil,
        type: [String],
        ingredients: [String],
        menuType: MenuType,
        stalls: Stalls? = nil,
        id: UUID = UUID()
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.desc = desc
        self.image = image
        self.type = type
        self.ingredients = ingredients
        self.menuType = menuType
        self.stalls = stalls
    }
}

enum MenuType: String, CaseIterable, Codable {
    case indonesian = "Indonesian"
    case western = "Western"
    case chinese = "Chinese"
    case japanese = "Japanese"
    case korean = "Korean"
    case javanese = "Javanese"
    case sundanese = "Sundanese"
}
