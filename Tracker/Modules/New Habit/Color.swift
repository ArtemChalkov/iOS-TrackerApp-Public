//
//  Color.swift
//  textfield-in-tableview
//

import UIKit

struct Color {
    let color: UIColor
    var isSelected: Bool
}

struct Colors {
    
    var items = [
        Color(color: colors[0], isSelected: false),
        Color(color: colors[1], isSelected: false),
        Color(color: colors[2], isSelected: false),
        Color(color: colors[3], isSelected: false),
        Color(color: colors[4], isSelected: false),
        Color(color: colors[5], isSelected: false),
        Color(color: colors[6], isSelected: false),
        Color(color: colors[7], isSelected: false),
        Color(color: colors[8], isSelected: false),
        Color(color: colors[9], isSelected: false),
        Color(color: colors[10], isSelected: false),
        Color(color: colors[11], isSelected: false),
        Color(color: colors[12], isSelected: false),
        Color(color: colors[13], isSelected: false),
        Color(color: colors[14], isSelected: false),
        Color(color: colors[15], isSelected: false),
        Color(color: colors[16], isSelected: false),
        Color(color: colors[17], isSelected: false)
    ]
    
    static let colors = [
        UIColor(named: "Color selection 1") ?? UIColor.black,
        UIColor(named: "Color selection 2") ?? UIColor.black,
        UIColor(named: "Color selection 3") ?? UIColor.black,
        UIColor(named: "Color selection 4") ?? UIColor.black,
        UIColor(named: "Color selection 5") ?? UIColor.black,
        UIColor(named: "Color selection 6") ?? UIColor.black,
        UIColor(named: "Color selection 7") ?? UIColor.black,
        UIColor(named: "Color selection 8") ?? UIColor.black,
        UIColor(named: "Color selection 9") ?? UIColor.black,
        UIColor(named: "Color selection 10") ?? UIColor.black,
        UIColor(named: "Color selection 11") ?? UIColor.black,
        UIColor(named: "Color selection 12") ?? UIColor.black,
        UIColor(named: "Color selection 13") ?? UIColor.black,
        UIColor(named: "Color selection 14") ?? UIColor.black,
        UIColor(named: "Color selection 15") ?? UIColor.black,
        UIColor(named: "Color selection 16") ?? UIColor.black,
        UIColor(named: "Color selection 17") ?? UIColor.black,
        UIColor(named: "Color selection 18") ?? UIColor.black
    ]
}


extension Colors {
    static let blue = UIColor(red: 55 / 255, green: 114 / 255, blue: 231 / 255, alpha: 1)
    static let lightGray1 = UIColor(red: 230 / 255, green: 232 / 255, blue: 235 / 255, alpha: 1)
    static let lightGray = UIColor(red: 230 / 255, green: 232 / 255, blue: 235 / 255, alpha: 0.3)
    static let black = UIColor(red: 26 / 255, green: 27 / 255, blue: 34 / 255, alpha: 1)
    static let gray = UIColor(red: 174 / 255, green: 175 / 255, blue: 180 / 255, alpha: 1)
    
    //Random Colors
    
    static let color1 = UIColor(red: 253 / 255, green: 76 / 255, blue: 73 / 255, alpha: 1)
    static let color2 = UIColor(red: 249 / 255, green: 212 / 255, blue: 212 / 255, alpha: 1)
    static let color3 = UIColor(red: 246 / 255, green: 196 / 255, blue: 139 / 255, alpha: 1)
    static let color4 = UIColor(red: 255 / 255, green: 153 / 255, blue: 204 / 255, alpha: 1)
}
