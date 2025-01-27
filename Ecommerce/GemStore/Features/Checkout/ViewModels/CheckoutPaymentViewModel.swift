//
//  CheckoutPaymentViewModel.swift
//  Ecommerce
//
//  Created by Imac on 27.01.25.
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

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
    private let ordersService: OrdersServiceProtocol
    private let cartService: CartServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var cartQuantity: Int = 0
    
    init(
        productPrice: Double,
        shippingPrice: Double = 0,
        paymentService: PaymentServiceProtocol = PaymentServiceImpl.shared,
        ordersService: OrdersServiceProtocol = OrdersService(),
        cartService: CartServiceProtocol = CartServiceImpl.shared
    ) {
        self.productPrice = productPrice
        self.shippingPrice = shippingPrice
        self.paymentService = paymentService
        self.ordersService = ordersService
        self.cartService = cartService
        
        setupBindings()
        Task {
            await loadCards()
        }
    }
    
    private func setupBindings() {
        cartService.totalQuantityPublisher
            .sink { [weak self] quantity in
                self?.cartQuantity = quantity
            }
            .store(in: &cancellables)
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
            let paymentSuccessful = try await processPayment()
            guard paymentSuccessful else {
                errorMessage = "Payment failed"
                return false
            }
            
            let order = Order(
                id: UUID().uuidString,
                trackingNumber: generateTrackingNumber(),
                quantity: cartQuantity,
                subtotal: totalAmount,
                status: .pending,
                date: Date()
            )
            
            try await createOrder(order)
            
            try await cartService.clearCart()
            
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    private func processPayment() async throws -> Bool {
        return true
    }
    
    private func createOrder(_ order: Order) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "CheckoutPayment", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let db = Firestore.firestore()
            let orderData: [String: Any] = [
                "id": order.id,
                "trackingNumber": order.trackingNumber,
                "quantity": order.quantity,
                "subtotal": order.subtotal,
                "status": order.status.rawValue,
                "date": Timestamp(date: order.date),
                "userId": userId
            ]
            
            db.collection("orders").document(order.id).setData(orderData) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    private func generateTrackingNumber() -> String {
        let prefix = "IK"
        let randomNum = Int.random(in: 10000000...99999999)
        return "\(prefix)\(randomNum)"
    }
}

enum PaymentMethod {
    case cash
    case creditCard
} 
