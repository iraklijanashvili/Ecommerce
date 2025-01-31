//
//  CartService.swift
//  Ecommerce
//
//  Created by Imac on 24.01.25.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

typealias CartService = CartServiceProtocol

protocol CartServiceProtocol {
    var items: [CartItem] { get }
    var itemsPublisher: AnyPublisher<[CartItem], Never> { get }
    var totalPrice: Double { get }
    var totalPricePublisher: AnyPublisher<Double, Never> { get }
    var totalQuantity: Int { get }
    var totalQuantityPublisher: AnyPublisher<Int, Never> { get }
    
    func addToCart(product: Product, quantity: Int, size: String, color: ProductColor)
    func removeFromCart(itemId: String)
    func updateQuantity(itemId: String, quantity: Int)
    func clearCart()
}

class CartServiceImpl: CartServiceProtocol {
    static let shared = CartServiceImpl()
    
    @Published private(set) var items: [CartItem] = []
    @Published private(set) var totalPrice: Double = 0
    @Published private(set) var totalQuantity: Int = 0
    
    private let repository: CartRepository
    private var cancellables = Set<AnyCancellable>()
    
    var itemsPublisher: AnyPublisher<[CartItem], Never> {
        $items.eraseToAnyPublisher()
    }
    
    var totalPricePublisher: AnyPublisher<Double, Never> {
        $totalPrice.eraseToAnyPublisher()
    }
    
    var totalQuantityPublisher: AnyPublisher<Int, Never> {
        $totalQuantity.eraseToAnyPublisher()
    }
    
    init(repository: CartRepository = CartRepositoryImpl()) {
        self.repository = repository
        setupBindings()
    }
    
    private func setupBindings() {
        repository.observeCartItems()
            .sink { [weak self] items in
                self?.items = items
                self?.updateDerivedValues(from: items)
            }
            .store(in: &cancellables)
    }
    
    private func updateDerivedValues(from items: [CartItem]) {
        totalPrice = items.reduce(0) { $0 + $1.totalPrice }
        totalQuantity = items.reduce(0) { $0 + $1.quantity }
    }
    
    func addToCart(product: Product, quantity: Int, size: String, color: ProductColor) {
        Task {
            let itemId = "\(product.id)_\(size)_\(color.rawValue)"
            let cartItem = CartItem(
                id: itemId,
                product: product,
                quantity: quantity,
                selectedSize: size,
                selectedColor: color
            )
            
            do {
                try await repository.addItem(cartItem)
            } catch {
                print("Error adding to cart: \(error)")
            }
        }
    }
    
    func removeFromCart(itemId: String) {
        Task {
            do {
                try await repository.removeItem(withId: itemId)
            } catch {
                print("Error removing from cart: \(error)")
            }
        }
    }
    
    func updateQuantity(itemId: String, quantity: Int) {
        Task {
            do {
                try await repository.updateItemQuantity(id: itemId, quantity: quantity)
            } catch {
                print("Error updating quantity: \(error)")
            }
        }
    }
    
    func clearCart() {
        Task {
            do {
                try await repository.clearCart()
            } catch {
                print("Error clearing cart: \(error)")
            }
        }
    }
} 
