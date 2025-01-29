//
//  Order.swift
//  Ecommerce
//
//  Created by Imac on 29.01.25.
//


import Foundation

enum OrderStatus: String {
    case pending = "PENDING"
    case delivered = "DELIVERED"
    case cancelled = "CANCELLED"
}

struct Order {
    let id: String
    let trackingNumber: String
    let quantity: Int
    let subtotal: Double
    let status: OrderStatus
    let date: Date
    let productName: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    var formattedSubtotal: String {
        return "$\(Int(subtotal))"
    }
} 
