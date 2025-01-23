//
//  CartItem.swift
//  Ecommerce
//
//  Created by Imac on 24.01.25.
//

import Foundation

struct CartItem: Identifiable, Codable {
    let id: String
    let product: Product
    let quantity: Int
    let selectedSize: String
    let selectedColor: ProductColor
    
    var totalPrice: Double {
        Double(quantity) * product.price
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case product
        case quantity
        case selectedSize
        case selectedColor
    }
    
    init(id: String, product: Product, quantity: Int, selectedSize: String, selectedColor: ProductColor) {
        self.id = id
        self.product = product
        self.quantity = quantity
        self.selectedSize = selectedSize
        self.selectedColor = selectedColor
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        product = try container.decode(Product.self, forKey: .product)
        quantity = try container.decode(Int.self, forKey: .quantity)
        selectedSize = try container.decode(String.self, forKey: .selectedSize)
        selectedColor = try container.decode(ProductColor.self, forKey: .selectedColor)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(product, forKey: .product)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(selectedSize, forKey: .selectedSize)
        try container.encode(selectedColor, forKey: .selectedColor)
    }
} 
