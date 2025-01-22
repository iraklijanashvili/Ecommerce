import Foundation

protocol ProductFilterService {
    func filterProducts(_ products: [Product], with filter: FilterOptions, searchQuery: String) -> [Product]
}

class ProductFilterServiceImpl: ProductFilterService {
    func filterProducts(_ products: [Product], with filter: FilterOptions, searchQuery: String) -> [Product] {
        var filtered = products
        
        filtered = filtered.filter { product in
            let price = Double(product.price)
            return price >= filter.priceRange.min && price <= filter.priceRange.max
        }
        
        if !filter.selectedCategories.isEmpty {
            filtered = filtered.filter { product in
                guard let productCategory = ProductCategory.fromString(product.categoryId) else {
                    return false
                }
                return filter.selectedCategories.contains(productCategory)
            }
        }
        
        if !filter.selectedColors.isEmpty {
            filtered = filtered.filter { product in
                guard let productColors = product.colors else {
                    return false
                }
                let productColorEnums = productColors.compactMap { ProductColor.fromString($0) }
                return !Set(productColorEnums).isDisjoint(with: filter.selectedColors)
            }
        }
        
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            filtered = filtered.filter { product in
                product.name.lowercased().contains(query) ||
                product.description.lowercased().contains(query)
            }
        }
        
        switch filter.sortBy {
        case .priceHighToLow:
            filtered.sort { (product1: Product, product2: Product) in
                product1.price > product2.price
            }
        case .priceLowToHigh:
            filtered.sort { (product1: Product, product2: Product) in
                product1.price < product2.price
            }
        case .none:
            break
        }
        
        return filtered
    }
} 
