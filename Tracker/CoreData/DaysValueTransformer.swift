//
//  DaysValueTransformer.swift
//  Tracker
//

import Foundation

@objc
final class DaysValueTransformer: ValueTransformer {
    
    //Кладет модель данных -> бинарник
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [DayOfWeek] else { return nil }
        return try? JSONEncoder().encode(days)
    }

    //Достает из бинарника -> модель данных
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([DayOfWeek].self, from: data as Data)
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))
        )
    }
}
