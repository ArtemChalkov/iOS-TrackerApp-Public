//
//  TrackerCategory.swift
//  Tracker
//

import Foundation

struct TrackerCategory: Equatable {
    
    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    
    let id: UUID
    let name: String
    
    var array: [Tracker] = []
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
    
    var data: Data {
        Data(id: id, name: name)
    }
}

extension TrackerCategory {
    struct Data {
        let id: UUID
        var name: String
        
        init(id: UUID? = nil, name: String = "") {
            self.id = id ?? UUID()
            self.name = name
        }
    }
}
