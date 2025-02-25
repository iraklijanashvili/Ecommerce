//
//  Product.swift
//  Ecommerce
//
//  Created by Imac on 16.01.25.
//

import Foundation

struct Product: Identifiable, Codable, Hashable {
    var id: String
    let name: String
    let description: String
    let price: Double
    let imageUrl: String?
    let categoryId: String
    let mainCategoryId: String
    let colors: [String]?
    let sizes: [String]?
    private var _types: [String]?
    let inventory: [String: [String: Int]]?
    let collectionType: String?
    let colorVariants: [String: ColorVariant]?
    
    struct ColorVariant: Codable {
        let image: String
        let inventory: [String: Int]
    }
    
    var types: [String]? {
        get { return _types }
    }
    
    var isFeatured: Bool {
        return types?.contains("featured") ?? false
    }
    
    var isRecommended: Bool {
        return types?.contains("recommended") ?? false
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return "$\(formatter.string(from: NSNumber(value: price)) ?? String(format: "%.0f", price))"
    }
    
    var defaultImageUrl: String {
        if let firstColor = colors?.first,
           let firstColorVariant = colorVariants?[firstColor] {
            return firstColorVariant.image
        }
        return imageUrl ?? ""
    }
    
    func getQuantity(for color: String, size: String) -> Int {
        if let colorVariant = colorVariants?[color] {
            return colorVariant.inventory[size] ?? 0
        }
        return inventory?[color]?[size] ?? 0
    }
    
    func isAvailable(color: String, size: String) -> Bool {
        return getQuantity(for: color, size: size) > 0
    }
    
    func getImageUrl(for color: String) -> String {
        if !color.isEmpty,
           let colorVariant = colorVariants?[color] {
            return colorVariant.image
        }
        return defaultImageUrl
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case imageUrl = "images"
        case categoryId
        case mainCategoryId
        case colors
        case sizes
        case _types = "types"
        case inventory
        case collectionType = "collection_type"
        case colorVariants
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        price = try container.decode(Double.self, forKey: .price)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        categoryId = try container.decode(String.self, forKey: .categoryId)
        mainCategoryId = try container.decode(String.self, forKey: .mainCategoryId)
        colors = try container.decodeIfPresent([String].self, forKey: .colors)
        sizes = try container.decodeIfPresent([String].self, forKey: .sizes)
        inventory = try container.decodeIfPresent([String: [String: Int]].self, forKey: .inventory)
        collectionType = try container.decodeIfPresent(String.self, forKey: .collectionType)
        colorVariants = try container.decodeIfPresent([String: ColorVariant].self, forKey: .colorVariants)
        
        if let typesArray = try? container.decode([String].self, forKey: ._types) {
            _types = typesArray
        } else if let typeString = try? container.decode(String.self, forKey: ._types) {
            _types = [typeString]
        } else {
            _types = nil
        }
    }
}
