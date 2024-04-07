//
//  UIColorValueTransformer.swift
//  Tracker
//

import Foundation

@objc
final class UIColorValueTransformer: ValueTransformer {
    
    static func register() {
        ValueTransformer.setValueTransformer(
            UIColorValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: UIColorValueTransformer.self))
        )
    }
}
