//
//  Colors.swift
//  Tracker
//


import UIKit

enum Colors {
    static let blue = UIColor(red: 55 / 255, green: 114 / 255, blue: 231 / 255, alpha: 1)
    
    static let lightGray = UIColor(red: 230 / 255, green: 232 / 255, blue: 235 / 255, alpha: 0.3)   
    
    static let black = UIColor(red: 26 / 255, green: 27 / 255, blue: 34 / 255, alpha: 1)
    
    static let gray = UIColor(red: 174 / 255, green: 175 / 255, blue: 180 / 255, alpha: 1)
    
    //Random Colors
    
    static let color1 = UIColor(red: 253 / 255, green: 76 / 255, blue: 73 / 255, alpha: 1)
    static let color2 = UIColor(red: 249 / 255, green: 212 / 255, blue: 212 / 255, alpha: 1)
    static let color3 = UIColor(red: 246 / 255, green: 196 / 255, blue: 139 / 255, alpha: 1)
    static let color4 = UIColor(red: 255 / 255, green: 153 / 255, blue: 204 / 255, alpha: 1)
    
    static func randomColor() -> UIColor {
        return [Colors.color1, Colors.color2, Colors.color3, Colors.color4].randomElement()!
    }
}

