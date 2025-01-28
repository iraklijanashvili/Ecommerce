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
    @Published private(set) var firstName: String = ""
    @Published private(set) var lastName: String = ""
    @Published var streetName: String = ""
    @Published var city: String = ""
    @Published var zipCode: String = ""
    @Published var phoneNumber: String = ""
    @Published var selectedCountry: String = "Georgia"
    @Published var selectedShippingMethod: ShippingMethod?
    @Published var totalAmount: Double = 0
    
    @Published var formErrors: [String: String] = [:]
    @Published var showValidationAlert = false
    
    @Published var countries: [String] = []
    @Published var shippingMethods: [ShippingMethod] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var navigateToPayment = false
    
    private var cancellables = Set<AnyCancellable>()
    private let userService: UserServiceProtocol
    let cartService: CartServiceProtocol
    private let shippingService: ShippingServiceProtocol
    
    init(
        userService: UserServiceProtocol = UserService(),
        cartService: CartServiceProtocol = CartServiceImpl.shared,
        shippingService: ShippingServiceProtocol = ShippingService()
    ) {
        self.userService = userService
        self.cartService = cartService
        self.shippingService = shippingService
        
        loadUserData()
        setupTotalAmountCalculation()
        Task {
            await loadShippingData()
        }
    }
    
    private func loadShippingData() async {
        await MainActor.run {
            self.isLoading = true
        }
        do {
            async let countriesTask = shippingService.fetchCountries()
            async let methodsTask = shippingService.fetchShippingMethods()
            
            let (countries, methods) = try await (countriesTask, methodsTask)
            
            await MainActor.run {
                self.countries = countries
                self.shippingMethods = methods
                self.selectedCountry = countries.first ?? "Georgia"
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func loadUserData() {
        Task { @MainActor in
            firstName = userService.currentUser?.firstName ?? ""
            lastName = userService.currentUser?.lastName ?? ""
        }
    }
    
    private func setupTotalAmountCalculation() {
        Publishers.CombineLatest(
            cartService.totalPricePublisher,
            $selectedShippingMethod.map { $0?.price ?? 0 }
        )
        .map { cartTotal, shippingPrice in
            cartTotal + shippingPrice
        }
        .receive(on: DispatchQueue.main)
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
            navigateToPayment = true
        } else {
            showValidationAlert = true
        }
    }
} 
