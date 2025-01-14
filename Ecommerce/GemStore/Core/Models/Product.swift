//
//  Product.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let price: Price
    let imageURL: String
    let description: String
    let category: Category
    let section: Section
    
    enum Section: String, Codable {
        case featured
        case recommended
    }
    
    struct Price: Codable, Hashable {
        let amount: Double
        let currency: Currency
        
        var formatted: String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency.rawValue
            return formatter.string(from: NSNumber(value: amount)) ?? "\(currency.symbol)\(amount)"
        }
        
        enum Currency: String, Codable {
            case usd = "USD"
            case eur = "EUR"
            case gbp = "GBP"
            
            var symbol: String {
                switch self {
                case .usd: return "$"
                case .eur: return "€"
                case .gbp: return "£"
                }
            }
        }
    }
    
    enum Category: String, Codable, CaseIterable {
        case women = "Women"
        case men = "Men"
        case accessories = "Accessories"
        case beauty = "Beauty"
        
        var icon: String {
            switch self {
            case .women: return "person.fill"
            case .men: return "person"
            case .accessories: return "eyeglasses"
            case .beauty: return "sparkles"
            }
        }
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        price: Double,
        currency: Price.Currency = .usd,
        imageURL: String,
        description: String = "",
        category: Category = .women,
        section: Section
    ) {
        self.id = id
        self.name = name
        self.price = Price(amount: price, currency: currency)
        self.imageURL = imageURL
        self.description = description
        self.category = category
        self.section = section
    }
}
