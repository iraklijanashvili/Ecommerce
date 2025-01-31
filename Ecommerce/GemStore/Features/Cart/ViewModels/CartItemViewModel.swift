//
//  CartItemViewModel.swift
//  Ecommerce
//
//  Created by Imac on 30.01.25.
//

import Foundation
import Combine

class CartItemViewModel: ObservableObject, CartItemState, CartItemInteractor {
    @Published private(set) var item: CartItem
    @Published private(set) var quantity: Int
    @Published private(set) var totalPrice: Double
    @Published private(set) var isUpdating: Bool = false
    
    private let updateHandler: CartItemUpdateHandler
    private var cancellables = Set<AnyCancellable>()
    
    init(item: CartItem, updateHandler: CartItemUpdateHandler) {
        self.item = item
        self.quantity = item.quantity
        self.totalPrice = item.product.price * Double(item.quantity)
        self.updateHandler = updateHandler
        
        setupBindings()
    }
    
    private func setupBindings() {
        $quantity
            .map { [weak self] quantity -> Double in
                guard let self = self else { return 0 }
                return self.item.product.price * Double(quantity)
            }
            .assign(to: &$totalPrice)
    }
    
    func incrementQuantity() {
        let newQuantity = quantity + 1
        updateQuantity(newQuantity)
    }
    
    func decrementQuantity() {
        guard quantity > 1 else {
            removeItem()
            return
        }
        let newQuantity = quantity - 1
        updateQuantity(newQuantity)
    }
    
    func removeItem() {
        isUpdating = true
        updateHandler.removeItem(itemId: item.id)
        isUpdating = false
    }
    
    private func updateQuantity(_ newQuantity: Int) {
        guard newQuantity > 0 else { return }
        
        isUpdating = true
        quantity = newQuantity
        updateHandler.updateQuantity(itemId: item.id, quantity: newQuantity)
        isUpdating = false
    }
} 
