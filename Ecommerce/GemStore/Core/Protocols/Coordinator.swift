//
//  Coordinator.swift
//  Ecommerce
//
//  Created by Imac on 30.01.25.
//

import SwiftUI

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    
    var parentCoordinator: Coordinator? { get set }
    
    var childCoordinators: [Coordinator] { get set }
    
    func start()
    
    func removeChildCoordinator(_ child: Coordinator)
}

extension Coordinator {
    func removeChildCoordinator(_ child: Coordinator) {
        childCoordinators.removeAll { $0 === child }
    }
    
    func present<T: View>(_ view: T, animated: Bool = true) {
        let hostingController = UIHostingController(rootView: view)
        navigationController.pushViewController(hostingController, animated: animated)
    }
    
    func dismiss(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }
} 
