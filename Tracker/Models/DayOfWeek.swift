//
//  WeekDay.swift
//  Tracker
//

import Foundation

enum DayOfWeek: String, CaseIterable, Codable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    func shortDay() -> String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    func index() -> Int {
        switch self {
        case .monday: return 0
        case .tuesday: return 1
        case .wednesday: return 2
        case .thursday: return 3
        case .friday: return 4
        case .saturday: return 5
        case .sunday: return 6
        }
    }
    
    static func < (lhs: DayOfWeek, rhs: DayOfWeek) -> Bool {
        guard
            let first = Self.allCases.firstIndex(of: lhs),
            let second = Self.allCases.firstIndex(of: rhs)
        else { return false }
        
        return first < second
    }
}

//extension DayOfWeek {
//
//    // [.monday, .saturday, .sunday] -> "Понедельник,Суббота,Воскресенье"
//    static func code(_ weekdays: [DayOfWeek] = []) -> String {
//        
//        var daysArray = weekdays.compactMap { $0.rawValue } 
//        // -> ["Понедельник", "Суббота", "Воскресенье"]
//        
//        var daysString = daysArray.joined(separator: ",") 
//        // -> "Понедельник,Суббота,Воскресенье"
//        
//        return daysString
//    }
//    
//    //"Понедельник,Суббота,Воскресенье" ->  [.monday, .saturday, .sunday]
//    static func decode(from string: String?) -> [DayOfWeek] {
//        
//        var daysString = string ?? ""
//        
//        var daysArrayResult = daysString.components(separatedBy: ",")
//        // -> ["Понедельник", "Суббота", "Воскресенье"]
//        
//        var daysResult: [DayOfWeek] = daysArrayResult.compactMap { DayOfWeek(rawValue: $0) } 
//        // -> [.monday, .saturday, .sunday]
//        
//        return daysResult
//        
//    }
//}

extension DayOfWeek {
    static func code(_ weekdays: [DayOfWeek]?) -> String? {
        
        guard let weekdays else { return nil }
        let indexes = weekdays.map { Self.allCases.firstIndex(of: $0) }
        var result = ""
        for i in 0..<7 { //[.monday, .tuesday] -> 1100000
            if indexes.contains(i) {
                result += "1"
            } else {
                result += "0"
            }
        }
        return result
    }
    
    //1100000 -> [.monday, .tuesday]
    static func decode(from string: String?) -> [DayOfWeek]? {
        guard let string else { return nil }
        var weekdays = [DayOfWeek]()
        for (index, value) in string.enumerated() {
            guard value == "1" else { continue }
            let weekday = Self.allCases[index]
            weekdays.append(weekday)
        }
        return weekdays
    }
}
