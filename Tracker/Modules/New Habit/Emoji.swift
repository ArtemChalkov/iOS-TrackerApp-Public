//
//  Emoji.swift
//  textfield-in-tableview
//

import Foundation

struct Emojis {
    var items = [
        Emoji(symbol: "🙂", isSelected: false),
        Emoji(symbol: "😻", isSelected: false),
        Emoji(symbol: "🌺", isSelected: false),
        Emoji(symbol: "🐶", isSelected: false),
        Emoji(symbol: "❤️", isSelected: false),
        Emoji(symbol: "😱", isSelected: false),
        Emoji(symbol: "😇", isSelected: false),
        Emoji(symbol: "😡", isSelected: false),
        Emoji(symbol: "🥶", isSelected: false),
        Emoji(symbol: "🤔", isSelected: false),
        Emoji(symbol: "🙌", isSelected: false),
        Emoji(symbol: "🍔", isSelected: false),
        Emoji(symbol: "🥦", isSelected: false),
        Emoji(symbol: "🏓", isSelected: false),
        Emoji(symbol: "🥇", isSelected: false),
        Emoji(symbol: "🎸", isSelected: false),
        Emoji(symbol: "🏝", isSelected: false),
        Emoji(symbol: "😪", isSelected: false),
    ]
}

struct Emoji {
    let symbol: String
    var isSelected: Bool
}
