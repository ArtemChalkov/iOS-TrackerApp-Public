//
//  UIWindow+keyWindow.swift
//  Tracker
//

import UIKit

extension UIWindow {
    
    static var key: UIWindow! {
        if #available(iOS 13, *) {
            return UIApplication
                    .shared
                    .connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first { $0.isKeyWindow }
            
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
