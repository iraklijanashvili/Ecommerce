//
//  ProductFilterService.swift
//  Ecommerce
//
//  Created by Imac on 31.01.25.
//



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
                let productCategoryId = product.categoryId.lowercased()
                return filter.selectedCategories.contains { category in
                    productCategoryId == category.rawValue.lowercased()
                }
            }
        }
        
        if !filter.selectedColors.isEmpty {
            filtered = filtered.filter { product in
                guard let productColors = product.colors else {
                    return false
                }
                let productColorStrings = productColors.map { $0.lowercased() }
                let selectedColorStrings = filter.selectedColors.map { $0.rawValue.lowercased() }
                return !Set(productColorStrings).isDisjoint(with: Set(selectedColorStrings))
            }
        }
        
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            filtered = filtered.filter { product in
                product.name.lowercased().contains(query) ||
                product.description.lowercased().contains(query) ||
                product.categoryId.lowercased().contains(query) ||
                product.mainCategoryId.lowercased().contains(query) ||
                (ProductCategory.fromString(product.categoryId)?.displayName.lowercased().contains(query) ?? false)
            }
        }
        
        switch filter.sortBy {
        case .priceHighToLow:
            filtered.sort { $0.price > $1.price }
        case .priceLowToHigh:
            filtered.sort { $0.price < $1.price }
        case .none:
            break
        }
        
        return filtered
    }
} 
