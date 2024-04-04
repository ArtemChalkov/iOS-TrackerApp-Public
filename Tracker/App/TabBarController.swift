//
//  TabBarController.swift
//  Tracker
//

import UIKit

final class TabBarController: UITabBarController {
    
    private var trackersVC: TrackersViewController = {
        let controller = TrackersViewController()
        let image = UIImage(named: "tracker")
        let selectedImage = UIImage(named: "tracker-selected")
        let tabItem = UITabBarItem.init(title: "Трекеры", image: image, selectedImage: selectedImage)
        controller.tabBarItem = tabItem
        return controller
    }()
    
    private var statisticsVC: StatisticsViewController = {
        let controller = StatisticsViewController()
        let image = UIImage(named: "stats")
        let selectedImage = UIImage(named: "stats-selected")
        let tabItem = UITabBarItem.init(title: "Статистика", image: image, selectedImage: selectedImage)
        controller.tabBarItem = tabItem
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topline = CALayer()
        topline.frame = CGRect(x: 0, y: 0, width: self.tabBar.frame.width, height: 1)
        topline.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        self.tabBar.layer.addSublayer(topline)
        
        viewControllers = [UINavigationController(rootViewController: trackersVC),
                           statisticsVC]
    }
    
}
