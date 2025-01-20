//
//  Product.swift
//  Ecommerce
//
//  Created by Imac on 16.01.25.
//

import Foundation

struct Product: Identifiable, Codable {
    var id: String
    let name: String
    let description: String
    let price: Double
    let imageUrl: String
    let categoryId: String
    let colors: [String]?
    let sizes: [String]?
    let types: [String]?
    let inventory: [String: [String: Int]]?
    
    var formattedPrice: String {
        "₾\(String(format: "%.2f", price))"
    }
    
    func getQuantity(for color: String, size: String) -> Int {
        return inventory?[color]?[size] ?? 0
    }
    
    func isAvailable(color: String, size: String) -> Bool {
        return getQuantity(for: color, size: size) > 0
    }
    
    var isFeatured: Bool {
        return types?.contains("featured") ?? false
    }
    
    var isRecommended: Bool {
        return types?.contains("recommended") ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case imageUrl = "images"
        case categoryId
        case colors
        case sizes
        case types
        case inventory
    }
}
