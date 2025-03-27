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
    var dietType: String
    var menuType: MenuType
    
    @Relationship var stalls: Stalls?
    
    init(
        id: UUID = UUID(),
        name: String,
        price: Double,
        desc: String,
        image: Data? = nil,
        type: [String],
        dietType: String,
        menuType: MenuType,
        stalls: Stalls? = nil
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.desc = desc
        self.image = image
        self.type = type
        self.dietType = dietType
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
