//
//  Tracker.swift
//  Tracker
//

import UIKit

struct Tracker {
    let id: UInt //название, цвет, эмоджи и распиcание.
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Date
    
}

struct TrackerCategory {
    let name: String
    let array: [Tracker]
}

struct TrackerRecord {
    let id: UInt
    let date: Date
}
