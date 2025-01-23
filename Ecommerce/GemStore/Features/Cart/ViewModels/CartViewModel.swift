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
    var itemsPublisher: AnyPublisher<[CartItem], Never> { get }
    var totalPrice: Double { get }
    var totalPricePublisher: AnyPublisher<Double, Never> { get }
    var shipping: String { get }
    
    func removeItem(id: String)
    func updateQuantity(itemId: String, quantity: Int)
    func clearCart()
    func proceedToCheckout()
}

class CartViewModel: CartViewModelProtocol, ObservableObject {
    @Published private(set) var items: [CartItem] = []
    @Published private(set) var totalPrice: Double = 0
    let shipping = "Freeship"
    
    private let cartService: CartService
    private var cancellables = Set<AnyCancellable>()
    
    var itemsPublisher: AnyPublisher<[CartItem], Never> {
        $items.eraseToAnyPublisher()
    }
    
    var totalPricePublisher: AnyPublisher<Double, Never> {
        $totalPrice.eraseToAnyPublisher()
    }
    
    init(cartService: CartService = CartServiceImpl.shared) {
        self.cartService = cartService
        setupBindings()
    }
    
    private func setupBindings() {
        cartService.itemsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$items)
        
        cartService.totalPricePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$totalPrice)
    }
    
    func removeItem(id: String) {
        cartService.removeFromCart(itemId: id)
    }
    
    func updateQuantity(itemId: String, quantity: Int) {
        guard quantity > 0 else {
            cartService.removeFromCart(itemId: itemId)
            return
        }
        cartService.updateQuantity(itemId: itemId, quantity: quantity)
    }
    
    func clearCart() {
        cartService.clearCart()
    }
    
    func proceedToCheckout() {
    }
} 
