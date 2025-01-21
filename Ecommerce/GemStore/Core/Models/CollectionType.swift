import Foundation

enum CollectionType {
    case new
    case top
    case summer
    
    var categoryId: String {
        switch self {
        case .new:
            return "newcollection"
        case .top:
            return "topcollection"
        case .summer:
            return "summercollection"
        }
    }
    
    var title: String {
        switch self {
        case .new:
            return "New Collection"
        case .top:
            return "საუკეთესო კოლექცია"
        case .summer:
            return "ზაფხულის კოლექცია"
        }
    }
} 
