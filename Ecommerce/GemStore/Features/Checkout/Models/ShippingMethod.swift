//
//  ShippingMethod.swift
//  Ecommerce
//
//  Created by Imac on 24.01.25.
//

import Foundation

struct ShippingMethod: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let price: Double
    let deliveryTime: String
    
    static func == (lhs: ShippingMethod, rhs: ShippingMethod) -> Bool {
        lhs.id == rhs.id
    }
} 
