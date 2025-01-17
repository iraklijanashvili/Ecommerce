import Foundation

struct Category: Identifiable, Codable {
    let id: String
    let name: String
    let imageUrl: String
    let subcategories: [String: Subcategory]
    
    var subcategoryArray: [Subcategory] {
        subcategories.values.sorted { $0.itemCount > $1.itemCount }
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