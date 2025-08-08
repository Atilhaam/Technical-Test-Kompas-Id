//
//  MainTabBarController.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 02/08/25.
//

import UIKit

class MainTabBarController: UITabBarController {
     override func viewDidLoad() {
         super.viewDidLoad()
         let homeVC = HomeViewController()
         homeVC.tabBarItem = UITabBarItem(title: "Berita Utama", image: UIImage(systemName: "newspaper"), tag: 0)
         let savedVC = SavedNewsViewController()
         savedVC.tabBarItem = UITabBarItem(title: "Saved", image: UIImage(systemName: "bookmark"), tag: 1)
         viewControllers = [homeVC, savedVC]
     }
 }
