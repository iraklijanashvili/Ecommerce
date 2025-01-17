//
//  Product.swift
//  Ecommerce
//
//  Created by Imac on 16.01.25.
//

import Foundation

struct Banner: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let imageUrl: String
    let link: String
    let isActive: Bool
    let type: String
    
    var bannerType: BannerType? {
        BannerType(rawValue: type)
    }
    
    enum BannerType: String {
        case main = "main"
        case newCollection = "new_collection"
        case topCollection = "top_collection"
        case summerCollection = "summer_collection"
        
        var displayTitle: String {
            switch self {
            case .main:
                return "მთავარი ბანერი"
            case .newCollection:
                return "ახალი კოლექცია"
            case .topCollection:
                return "საუკეთესო კოლექცია"
            case .summerCollection:
                return "ზაფხულის კოლექცია"
            }
        }
    }
} 


