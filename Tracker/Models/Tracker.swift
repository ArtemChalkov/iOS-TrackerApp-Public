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
    
    let category: TrackerCategory
    let isPinned: Bool
    
    let daysCount: Int
    var schedule: [DayOfWeek]?
    
    init(id: UUID = UUID(), name: String, emoji: String, color: UIColor, category: TrackerCategory, isPinned: Bool, daysCount: Int,  schedule: [DayOfWeek]?) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        
        self.category = category
        self.isPinned = isPinned
        
        self.daysCount = daysCount
        self.schedule = schedule
        
    }
    
    init(tracker: Tracker) {
        self.id = tracker.id
        self.name = tracker.name
        self.emoji = tracker.emoji
        self.color = tracker.color
        
        self.category = tracker.category
        self.isPinned = tracker.isPinned
        
        self.daysCount = tracker.daysCount
        self.schedule = tracker.schedule
    }
    
    init(data: Data) {
        guard let emoji = data.emoji, let color = data.color, let category = data.category else { fatalError() }
        
        
        self.id = UUID()
        self.name = data.name
        self.emoji = emoji
        self.color = color
        self.category = category
        self.isPinned = data.isPinned
        
        self.daysCount = data.daysCount
        self.schedule = data.schedule
    }
    
    var data: Data {
        Data(name: name, emoji: emoji, color: color, category: category,  daysCount: daysCount, schedule: schedule)
    }
}

extension Tracker {
    struct Data {
        var name: String = ""
        var emoji: String? = nil
        var color: UIColor? = nil
        
        var category: TrackerCategory? = nil
        var isPinned: Bool = false
        
        var daysCount: Int = 0
        var schedule: [DayOfWeek]? = nil
    }
}

