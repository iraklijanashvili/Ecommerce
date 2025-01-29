//
//  Banner.swift
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
        case newCollection = "new_collection"
        case topCollection = "top_collection"
        case summerCollection = "summer_collection"
        
        var displayTitle: String {
            switch self {
            case .newCollection:
                return "New Collection"
            case .topCollection:
                return "Top Collection"
            case .summerCollection:
                return "Summer Collection"
            }
        }
    }
} 


