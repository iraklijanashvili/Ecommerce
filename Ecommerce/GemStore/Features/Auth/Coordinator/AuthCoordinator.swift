//
//  AuthCoordinator.swift
//  Ecommerce
//
//  Created by Imac on 30.01.25.
//

import SwiftUI
import UIKit

final class AuthCoordinator: Coordinator {
    var navigationController: UINavigationController
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showLoginView()
    }
    
    
    private func showLoginView() {
        let loginViewModel = LoginViewModel()
        let loginVC = LoginViewController(viewModel: loginViewModel)
        navigationController.pushViewController(loginVC, animated: true)
    }
    
    func showSignUpView() {
        let signUpViewModel = SignUpViewModel()
        let signUpVC = SignUpViewController(viewModel: signUpViewModel)
        navigationController.pushViewController(signUpVC, animated: true)
    }
    
    func showForgotPasswordView() {
    }
    
    
    func didFinishAuth() {
        parentCoordinator?.removeChildCoordinator(self)
    }
} 
