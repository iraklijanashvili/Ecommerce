//
//  CheckoutPaymentViewModel.swift
//  Ecommerce
//
//  Created by Imac on 27.01.25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class CheckoutPaymentViewModel: ObservableObject {
    @Published var selectedPaymentMethod: PaymentMethod?
    @Published var selectedCard: PaymentCard?
    @Published var cards: [PaymentCard] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let productPrice: Double
    let shippingPrice: Double
    
    private let paymentService: PaymentServiceProtocol
    
    init(
        productPrice: Double,
        shippingPrice: Double = 0,
        paymentService: PaymentServiceProtocol = PaymentServiceImpl.shared
    ) {
        self.productPrice = productPrice
        self.shippingPrice = shippingPrice
        self.paymentService = paymentService
        
        Task {
            await loadCards()
        }
    }
    
    var totalAmount: Double {
        productPrice + shippingPrice
    }
    
    func loadCards() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            cards = try await paymentService.fetchCards()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    var canPlaceOrder: Bool {
        switch selectedPaymentMethod {
        case .cash:
            return true
        case .creditCard:
            return selectedCard != nil
        case .none:
            return false
        }
    }
    
    func placeOrder() async -> Bool {
        guard canPlaceOrder else {
            errorMessage = "Please select a payment method"
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

enum PaymentMethod {
    case cash
    case creditCard
} 
