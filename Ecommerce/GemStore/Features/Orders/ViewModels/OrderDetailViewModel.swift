//
//  OrderDetailViewModel.swift
//  Ecommerce
//
//  Created by Imac on 29.01.25.
//

import Foundation

class OrderDetailViewModel {
    private let order: Order
    
    var orderNumber: String { "#\(String(order.id.prefix(6)))" }
    var trackingNumber: String { String(order.trackingNumber.prefix(6)) }
    var quantity: String { "\(order.quantity)" }
    var subtotal: String { order.formattedSubtotal }
    var status: OrderStatus { order.status }
    var date: String { order.formattedDate }
    var productName: String { order.productName }
    
    init(order: Order) {
        self.order = order
    }
} 
