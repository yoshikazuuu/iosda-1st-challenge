//
//  Item.swift
//  MakanMurah
//
//  Created by Jerry Febriano on 19/03/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
