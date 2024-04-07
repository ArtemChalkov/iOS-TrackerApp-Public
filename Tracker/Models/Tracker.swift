//
//  Tracker.swift
//  Tracker
//

import UIKit

struct Tracker {
    let id: UUID //название, цвет, эмоджи и распиcание.
    var name: String
    let color: UIColor
    let emoji: String
    let daysCount: Int
    
    //var schedule: Date?
    var schedule: [DayOfWeek]?
    
    init(id: UUID = UUID(), name: String, emoji: String, color: UIColor, daysCount: Int, schedule: [DayOfWeek]?) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.daysCount = daysCount
        self.schedule = schedule
    }
    
    init(tracker: Tracker) {
        self.id = tracker.id
        self.name = tracker.name
        self.emoji = tracker.emoji
        self.color = tracker.color
        self.daysCount = tracker.daysCount
        self.schedule = tracker.schedule
    }
    
    init(data: Data) {
        guard let emoji = data.emoji, let color = data.color else { fatalError() }
        
        self.id = UUID()
        self.name = data.name
        self.emoji = emoji
        self.color = color
        self.daysCount = data.daysCount
        self.schedule = data.schedule
    }
    
    var data: Data {
        Data(name: name, emoji: emoji, color: color, daysCount: daysCount, schedule: schedule)
    }
}

extension Tracker {
    struct Data {
        var name: String = ""
        var emoji: String? = nil
        var color: UIColor? = nil
        var daysCount: Int = 0
        var schedule: [DayOfWeek]? = nil
    }
}

