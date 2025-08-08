//
//  ViewController.swift
//  Technical Test Kompas
//
//  Created by Ilham Wibowo on 02/08/25.
//

import UIKit
import SwiftUI

class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = Injection.init().provideHomeViewModel()
        let navigator = Injection.init().provideHomeNavigator()
        let swiftUIView = NavigationStack {
            HomeView(viewModel: viewModel, navigator: navigator)
        }
        
        let hostingController = UIHostingController(rootView: swiftUIView)
       
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

