//
//  CartItemModels.swift
//  Ecommerce
//
//  Created by Imac on 30.01.25.
//


import Foundation

struct CartItemPrice {
    let unitPrice: Double
    let quantity: Int
    
    var total: Double {
        return unitPrice * Double(quantity)
    }
    
    static func zero() -> CartItemPrice {
        return CartItemPrice(unitPrice: 0, quantity: 0)
    }
}

protocol CartItemState {
    var item: CartItem { get }
    var quantity: Int { get }
    var totalPrice: Double { get }
    var isUpdating: Bool { get }
}

protocol CartItemInteractor {
    func incrementQuantity()
    func decrementQuantity()
    func removeItem()
} 
