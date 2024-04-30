//
//  Colors.swift
//  Tracker
//

import UIKit

struct Color {
    let id: Int
    let color: UIColor
    var isSelected: Bool
}

struct Colors {
    
    var items = [
        Color(id: 1, color: colors[0], isSelected: false),
        Color(id: 2, color: colors[1], isSelected: false),
        Color(id: 3, color: colors[2], isSelected: false),
        Color(id: 4, color: colors[3], isSelected: false),
        Color(id: 5, color: colors[4], isSelected: false),
        Color(id: 6, color: colors[5], isSelected: false),
        Color(id: 7, color: colors[6], isSelected: false),
        Color(id: 8, color: colors[7], isSelected: false),
        Color(id: 9, color: colors[8], isSelected: false),
        Color(id: 10, color: colors[9], isSelected: false),
        Color(id: 11, color: colors[10], isSelected: false),
        Color(id: 12, color: colors[11], isSelected: false),
        Color(id: 13, color: colors[12], isSelected: false),
        Color(id: 14, color: colors[13], isSelected: false),
        Color(id: 15, color: colors[14], isSelected: false),
        Color(id: 16, color: colors[15], isSelected: false),
        Color(id: 17, color: colors[16], isSelected: false),
        Color(id: 18, color: colors[17], isSelected: false)
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

extension UIColor {

    static var BlackDay: UIColor { UIColor(named: "Black [day]") ?? UIColor.black }
    static var BlackNight: UIColor { UIColor(named: "Black [night]") ?? UIColor.white }
    static var WhiteDay: UIColor { UIColor(named: "White [day]") ?? UIColor.white }
    static var WhiteNight: UIColor { UIColor(named: "White [night]") ?? UIColor.black }
    static var Blue: UIColor { UIColor(named: "Blue") ?? UIColor.blue }
    static var Red: UIColor { UIColor(named: "Red") ?? UIColor.red }
    static var BackgroundDay: UIColor { UIColor(named: "Background [day]") ?? UIColor.gray }
    static var Gray: UIColor { UIColor(named: "Gray") ?? UIColor.gray }
    static var LightGray: UIColor { UIColor(named: "Light Gray") ?? UIColor.lightGray }
    
    static let bunchOfSChoices = [
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
    
    static let gradient = [
        UIColor(named: "gBlue") ?? UIColor.black,
        UIColor(named: "gGreen") ?? UIColor.black,
        UIColor(named: "gRed") ?? UIColor.black,
    ]
}
