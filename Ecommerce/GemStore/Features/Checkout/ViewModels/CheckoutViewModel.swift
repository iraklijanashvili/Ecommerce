//
//  CheckoutViewModel.swift
//  Ecommerce
//
//  Created by Imac on 24.01.25.
//

import Foundation
import Combine
import SwiftUI

class CheckoutViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var streetName: String = ""
    @Published var city: String = ""
    @Published var zipCode: String = ""
    @Published var phoneNumber: String = ""
    @Published var selectedCountry: String = "Georgia"
    @Published var selectedShippingMethod: ShippingMethod?
    @Published var totalAmount: Double = 0
    
    @Published var formErrors: [String: String] = [:]
    @Published var showValidationAlert = false
    
    let countries = ["Georgia", "United States", "United Kingdom", "Germany", 
                    "France", "Italy", "Spain", "Japan", "Canada", "Australia"]
    
    let shippingMethods: [ShippingMethod] = [
        ShippingMethod(
            title: "Free",
            description: "Delivery to home",
            price: 0,
            deliveryTime: "Delivery from 5 to 7 business days"
        ),
        ShippingMethod(
            title: "$ 9.90",
            description: "Delivery to home",
            price: 9.90,
            deliveryTime: "Delivery from 2 to 4 business days"
        ),
        ShippingMethod(
            title: "$ 9.90",
            description: "Fast Delivery",
            price: 9.90,
            deliveryTime: "Delivery from 2 to 3 business days"
        )
    ]
    
    private var cancellables = Set<AnyCancellable>()
    private let userService: UserServiceProtocol
    let cartService: CartServiceProtocol
    
    init(userService: UserServiceProtocol = UserService(), 
         cartService: CartServiceProtocol = CartServiceImpl.shared) {
        self.userService = userService
        self.cartService = cartService
        
        loadUserData()
        setupTotalAmountCalculation()
    }
    
    private func loadUserData() {
        firstName = userService.currentUser?.firstName ?? ""
        lastName = userService.currentUser?.lastName ?? ""
    }
    
    private func setupTotalAmountCalculation() {
        Publishers.CombineLatest(
            cartService.totalPricePublisher,
            $selectedShippingMethod.map { $0?.price ?? 0 }
        )
        .map { cartTotal, shippingPrice in
            cartTotal + shippingPrice
        }
        .assign(to: &$totalAmount)
    }
    
    var isFormValid: Bool {
        formErrors.removeAll()
        
        if firstName.isEmpty {
            formErrors["firstName"] = "First name is required"
        }
        if lastName.isEmpty {
            formErrors["lastName"] = "Last name is required"
        }
        if streetName.isEmpty {
            formErrors["streetName"] = "Street name is required"
        }
        if city.isEmpty {
            formErrors["city"] = "City is required"
        }
        if zipCode.isEmpty {
            formErrors["zipCode"] = "ZIP code is required"
        }
        if phoneNumber.isEmpty {
            formErrors["phoneNumber"] = "Phone number is required"
        }
        if selectedShippingMethod == nil {
            formErrors["shippingMethod"] = "Please select a shipping method"
        }
        
        return formErrors.isEmpty
    }
    
    func proceedToPayment() {
        if isFormValid {
        } else {
            showValidationAlert = true
        }
    }
} 
