//
//  CartViewModel.swift
//  Ecommerce
//
//  Created by Imac on 24.01.25.
//

import Foundation
import Combine

protocol CartViewModelProtocol {
    var items: [CartItem] { get }
    var totalPrice: Double { get }
    var itemsPublisher: AnyPublisher<[CartItem], Never> { get }
    var totalPricePublisher: AnyPublisher<Double, Never> { get }
    
    func clearCart()
    func proceedToCheckout()
}

protocol CartItemUpdateHandler {
    func updateQuantity(itemId: String, quantity: Int)
    func removeItem(itemId: String)
}

class CartViewModel: ObservableObject, CartViewModelProtocol, CartItemUpdateHandler {
    @Published private(set) var items: [CartItem] = []
    @Published private(set) var totalPrice: Double = 0
    let shipping = "Freeship"
    
    private let cartService: CartServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var itemsPublisher: AnyPublisher<[CartItem], Never> {
        $items.eraseToAnyPublisher()
    }
    
    var totalPricePublisher: AnyPublisher<Double, Never> {
        $totalPrice.eraseToAnyPublisher()
    }
    
    init(cartService: CartServiceProtocol = CartServiceImpl.shared) {
        self.cartService = cartService
        setupBindings()
    }
    
    private func setupBindings() {
        cartService.itemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.items = items
            }
            .store(in: &cancellables)
        
        cartService.totalPricePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] price in
                self?.totalPrice = price
            }
            .store(in: &cancellables)
    }
    
    func updateQuantity(itemId: String, quantity: Int) {
        guard quantity > 0 else {
            removeItem(itemId: itemId)
            return
        }
        cartService.updateQuantity(itemId: itemId, quantity: quantity)
    }
    
    func removeItem(itemId: String) {
        cartService.removeFromCart(itemId: itemId)
    }
    
    func clearCart() {
        cartService.clearCart()
    }
    
    func proceedToCheckout() {
    }
} 
