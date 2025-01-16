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
    let linkId: String
    let linkType: BannerType
    
    enum BannerType: String, Codable {
        case main = "main"
        case newCollection = "new_collection"
        case topCollection = "top_collection"
        case summerCollection = "summer_collection"
        
        var displayTitle: String {
            switch self {
            case .main:
                return "Main Banner"
            case .newCollection:
                return "New Collection"
            case .topCollection:
                return "Top Collection"
            case .summerCollection:
                return "Summer Collection"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case imageUrl = "image_url"
        case linkId = "link_id"
        case linkType = "type"
    }
} 


