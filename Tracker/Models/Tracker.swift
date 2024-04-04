//
//  Tracker.swift
//  Tracker
//

import UIKit


struct Emojis {
    
    static func randomEmoji() -> String {
        let emojis = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]
        
        return emojis.randomElement()!
    }
}

struct Tracker {
    let id: UUID //название, цвет, эмоджи и распиcание.
    var name: String
    let color: UIColor
    let emoji: String
    //var schedule: Date?
    var schedule: [Weekday] = []
}

struct TrackerCategory {
    let name: String
    var array: [Tracker]
}

struct TrackerRecord {
    let id: UUID
    let date: Date
}
