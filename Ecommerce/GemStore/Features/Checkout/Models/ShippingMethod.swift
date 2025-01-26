//
//  ShippingMethod.swift
//  Ecommerce
//
//  Created by Imac on 24.01.25.
//

import Foundation
import FirebaseFirestore

struct ShippingMethod: Identifiable, Equatable, Codable {
    let id: String
    let title: String
    let description: String
    let price: Double
    let deliveryTime: String
    
    static func == (lhs: ShippingMethod, rhs: ShippingMethod) -> Bool {
        lhs.id == rhs.id
    }
} 
