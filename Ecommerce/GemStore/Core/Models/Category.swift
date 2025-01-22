//
//  Category.swift
//  Ecommerce
//
//  Created by Imac on 16.01.25.
//



import Foundation

struct Category: Identifiable, Codable {
    let id: String
    let name: String
    let imageUrl: String
    let subcategories: [String: Subcategory]
    
    var subcategoryArray: [Subcategory] {
        var array = Array(subcategories.values)
        let allSubcategory = Subcategory(id: "all", name: "All", itemCount: array.reduce(0) { $0 + $1.itemCount })
        array.insert(allSubcategory, at: 0)
        let sortedSubcategories = array[1...].sorted { $0.itemCount > $1.itemCount }
        return [allSubcategory] + sortedSubcategories
    }
    
    struct Subcategory: Codable {
        let id: String
        let name: String
        let itemCount: Int
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case itemCount = "item_count"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageUrl = "imageUrl"
        case subcategories
    }
} 
