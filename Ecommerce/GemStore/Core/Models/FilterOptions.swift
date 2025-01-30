enum ProductCategory: String, CaseIterable {
    case jackets = "jackets"
    case hoodies = "hoodie"
    case dresses = "dresses"
    case bags = "bags"
    case jewelry = "jewelry"
    case newCollection = "new collection"
    case topCollection = "top collection"
    case summerCollection = "summer collection"
    case athleticShoes = "athletic shoes"
    case casualShoes = "casual shoes"
    
    var displayName: String {
        switch self {
        case .hoodies:
            return "Hoodies"
        case .newCollection:
            return "New Collection"
        case .topCollection:
            return "Top Collection"
        case .summerCollection:
            return "Summer Collection"
        case .athleticShoes:
            return "Athletic Shoes"
        case .casualShoes:
            return "Casual Shoes"
        default:
            return rawValue.capitalized
        }
    }
} 