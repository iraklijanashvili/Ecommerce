//
//  OrderCompletedViewModel.swift
//  Ecommerce
//
//  Created by Imac on 27.01.25.
//

import Foundation
import SwiftUI

protocol OrderCompletionNavigationDelegate {
    func navigateToMyOrders()
    func navigateToHome()
}

@MainActor
class OrderCompletedViewModel: ObservableObject {
    private let navigationDelegate: OrderCompletionNavigationDelegate
    
    init(navigationDelegate: OrderCompletionNavigationDelegate) {
        self.navigationDelegate = navigationDelegate
    }
    
    func continueToHome() {
        navigationDelegate.navigateToHome()
    }
    
    func viewMyOrders() {
        navigationDelegate.navigateToMyOrders()
    }
} 
