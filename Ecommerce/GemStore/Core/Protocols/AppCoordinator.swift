//
//  AppCoordinator.swift
//  Ecommerce
//
//  Created by Imac on 30.01.25.
//

import SwiftUI
import UIKit

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        showAuthFlow()
    }
    
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    
    private func showAuthFlow() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.parentCoordinator = self
        addChildCoordinator(authCoordinator)
        authCoordinator.start()
    }
} 
