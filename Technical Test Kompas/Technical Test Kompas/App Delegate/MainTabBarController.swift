//
//  MainTabBarController.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 02/08/25.
//

import UIKit
import SwiftUI

class MainTabBarController: UITabBarController {
     override func viewDidLoad() {
         super.viewDidLoad()
         
         let viewModelHome = Injection.init().provideHomeViewModel()
         let navigatorHome = Injection.init().provideHomeNavigator()
         let swiftUIViewHome = NavigationStack {
             HomeView(viewModel: viewModelHome, navigator: navigatorHome)
         }
         let homeVC = UIHostingController(rootView: swiftUIViewHome)
         
         let viewModelSaved = Injection.init().provideSavedViewModel()
         let navigatorSaved = Injection.init().provideSavedNavigator()
         let swiftUIViewSaved = NavigationStack {
             SavedNewsView(viewModel: viewModelSaved, navigator: navigatorSaved)
         }
         let savedVC = UIHostingController(rootView: swiftUIViewSaved)
         
         homeVC.tabBarItem = UITabBarItem(title: "Berita Utama", image: UIImage(systemName: "newspaper"), tag: 0)
         savedVC.tabBarItem = UITabBarItem(title: "Saved", image: UIImage(systemName: "bookmark"), tag: 1)
         viewControllers = [homeVC, savedVC]
     }
 }
