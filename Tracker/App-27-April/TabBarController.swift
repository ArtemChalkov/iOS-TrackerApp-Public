//
//  TabBarController.swift
//  Tracker
//

import UIKit

final class TabBarController: UITabBarController {
    
    private var trackersVC: TrackersViewController = {
        let trackerStore = TrackerStore()
        let controller = TrackersViewController(trackerStore: trackerStore)
        let image = UIImage(named: "tracker")
        let selectedImage = UIImage(named: "tracker-selected")
        
        let title = "TabBar.trackers".localized
        let tabItem = UITabBarItem.init(title: title, image: image, selectedImage: selectedImage)
        controller.tabBarItem = tabItem
        return controller
    }()
    
    private var statisticsVC: StatisticViewController = {

        let controller = StatisticViewController()
        let statisticViewModel = StatisticViewModel()
        controller.statisticViewModel = statisticViewModel
        
        let image = UIImage(named: "stats")
        let selectedImage = UIImage(named: "stats-selected")

        let title = "TabBar.statistics".localized
        let tabItem = UITabBarItem.init(title: title, image: image, selectedImage: selectedImage)
        controller.tabBarItem = tabItem
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: "onboardingIsProcessed")
        
        let topline = CALayer()
        topline.frame = CGRect(x: 0, y: 0, width: self.tabBar.frame.width, height: 1)
        topline.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        self.tabBar.layer.addSublayer(topline)
        
        viewControllers = [UINavigationController(rootViewController: trackersVC),
                           statisticsVC]
    }
    
}
