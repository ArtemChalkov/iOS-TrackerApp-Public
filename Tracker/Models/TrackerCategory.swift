//
//  TrackerCategory.swift
//  Tracker
//

import Foundation

struct TrackerCategory {
    let id: UUID
    let name: String
    
    var array: [Tracker] = []
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
