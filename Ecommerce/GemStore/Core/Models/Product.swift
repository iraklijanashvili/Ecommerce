//
//  Product.swift
//  Ecommerce
//
//  Created by Imac on 16.01.25.
//

import Foundation

struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let images: String
    let categoryId: String
    let colors: [String]
    let sizes: [String]
    let types: [ProductType]
    
    var formattedPrice: String {
        "$\(String(format: "%.2f", price))"
    }
    
    enum ProductType: String, Codable {
        case featured = "featured"
        case recommended = "recommended"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        price = try container.decode(Double.self, forKey: .price)
        images = try container.decode(String.self, forKey: .images)
        categoryId = try container.decode(String.self, forKey: .categoryId)
        colors = try container.decode([String].self, forKey: .colors)
        sizes = try container.decode([String].self, forKey: .sizes)
        
        if let typeStrings = try container.decodeIfPresent([String].self, forKey: .types) {
            types = typeStrings.compactMap { ProductType(rawValue: $0) }
        } else {
            types = [.recommended]
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case images
        case categoryId
        case colors
        case sizes
        case types
    }
}
