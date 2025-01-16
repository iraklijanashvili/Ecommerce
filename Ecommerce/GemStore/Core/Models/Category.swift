//
//  Category.swift
//  Ecommerce
//
//  Created by Imac on 16.01.25.
//


import Foundation

extension Product {
    enum Category: String, CaseIterable, Identifiable, Hashable {
        case women = "Women"
        case men = "Men"
        case accessories = "Accessories"
        case beauty = "Beauty"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .women: return "person.fill"
            case .men: return "person"
            case .accessories: return "eyeglasses"
            case .beauty: return "sparkles"
            }
        }
    }
} 
