//
//  FilterOptions.swift
//  Ecommerce
//
//  Created by Imac on 21.01.25.
//


import Foundation
import UIKit

struct PriceRange {
    var min: Double
    var max: Double
}

enum SortOption {
    case none
    case priceHighToLow
    case priceLowToHigh
}

enum ProductCategory: String, CaseIterable {
    case jackets = "jackets"
    case hoodies = "hoodies"
    case dresses = "dresses"
    
    var displayName: String {
        rawValue.capitalized
    }
    
    static func fromString(_ string: String) -> ProductCategory? {
        return ProductCategory.allCases.first { $0.rawValue.lowercased() == string.lowercased() }
    }
}

enum ProductColor: String, CaseIterable {
    case black = "black"
    case blue = "blue"
    case red = "red"
    case white = "white"
    case brown = "brown"
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var uiColor: UIColor {
        switch self {
        case .black: return .black
        case .blue: return .blue
        case .red: return .red
        case .white: return .white
        case .brown: return .brown
        }
    }
    
    static func fromString(_ string: String) -> ProductColor? {
        return ProductColor.allCases.first { $0.rawValue.lowercased() == string.lowercased() }
    }
}

struct FilterOptions {
    var priceRange: PriceRange
    var selectedColors: Set<ProductColor>
    var selectedCategories: Set<ProductCategory>
    var sortBy: SortOption
    
    init(priceRange: PriceRange = PriceRange(min: 0, max: 1000),
         selectedColors: Set<ProductColor> = [],
         selectedCategories: Set<ProductCategory> = [],
         sortBy: SortOption = .none) {
        self.priceRange = priceRange
        self.selectedColors = selectedColors
        self.selectedCategories = selectedCategories
        self.sortBy = sortBy
    }
} 
