//
//  DiscoverViewModel.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import Foundation

protocol CategoryRepository {
    func fetchCategories() async throws -> [Category]
    func fetchProducts(for categoryId: String) async throws -> [Product]
    func fetchAllProducts() async throws -> [Product]
}

protocol DiscoverViewModelProtocol: AnyObject {
    var categories: [Category] { get }
    var products: [Product] { get }
    var filteredProducts: [Product] { get }
    var currentFilter: FilterOptions { get }
    var searchQuery: String { get }
    var onCategoriesUpdated: (() -> Void)? { get set }
    var onProductsUpdated: (() -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    
    func fetchCategories()
    func fetchAllProducts()
    func fetchProducts(for categoryId: String)
    func applyFilter(_ filter: FilterOptions)
    func resetFilter()
    func search(query: String)
}

class FirebaseCategoryRepository: CategoryRepository {
    private let firestoreService: FirestoreService
    
    init(firestoreService: FirestoreService = FirestoreServiceImpl()) {
        self.firestoreService = firestoreService
    }
    
    func fetchCategories() async throws -> [Category] {
        return try await firestoreService.fetchCategories()
    }
    
    func fetchProducts(for categoryId: String) async throws -> [Product] {
        return try await firestoreService.getProducts(for: categoryId)
    }
    
    func fetchAllProducts() async throws -> [Product] {
        return try await firestoreService.fetchProducts()
    }
}

class DiscoverViewModel: ObservableObject, DiscoverViewModelProtocol {
    private let repository: CategoryRepository
    
    @Published private(set) var categories: [Category] = []
    @Published private(set) var products: [Product] = []
    @Published private(set) var filteredProducts: [Product] = []
    @Published private(set) var currentFilter = FilterOptions()
    @Published private(set) var searchQuery: String = ""
    
    var onCategoriesUpdated: (() -> Void)?
    var onProductsUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(repository: CategoryRepository = FirebaseCategoryRepository()) {
        self.repository = repository
    }
    
    func fetchCategories() {
        Task {
            do {
                print("Starting to fetch categories...")
                categories = try await repository.fetchCategories()
                print("Successfully fetched \(categories.count) categories")
                await MainActor.run {
                    onCategoriesUpdated?()
                }
            } catch {
                print("Error fetching categories: \(error)")
                await MainActor.run {
                    onError?(error)
                }
            }
        }
    }
    
    func fetchAllProducts() {
        Task {
            do {
                print("Fetching all products...")
                let allProducts = try await repository.fetchAllProducts()
                
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.products = allProducts
                    self.filteredProducts = allProducts
                    print("Fetched \(allProducts.count) products")
                    self.onProductsUpdated?()
                }
            } catch {
                print("Error fetching all products: \(error)")
                await MainActor.run { [weak self] in
                    self?.onError?(error)
                }
            }
        }
    }
    
    func fetchProducts(for categoryId: String) {
        Task {
            do {
                print("Fetching products for category: \(categoryId)")
                let fetchedProducts = try await repository.fetchProducts(for: categoryId)
                
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.products = fetchedProducts
                    self.filteredProducts = fetchedProducts
                    print("Fetched products count: \(fetchedProducts.count)")
                    self.onProductsUpdated?()
                }
            } catch {
                print("Error fetching products: \(error)")
                await MainActor.run { [weak self] in
                    self?.onError?(error)
                }
            }
        }
    }
    
    func search(query: String) {
        searchQuery = query.lowercased()
        applyCurrentFilter()
    }
    
    func applyFilter(_ filter: FilterOptions) {
        currentFilter = filter
        applyCurrentFilter()
    }
    
    func resetFilter() {
        currentFilter = FilterOptions()
        searchQuery = ""
        filteredProducts = products
        onProductsUpdated?()
    }
    
    private func applyCurrentFilter() {
        print("\n=== Starting filter with \(products.count) products ===")
        
        var matchingProducts = products
        
        matchingProducts = matchingProducts.filter { product in
            var shouldInclude = true
            
            if !currentFilter.selectedCategories.isEmpty {
                let categoryMatches = currentFilter.selectedCategories.contains { category in
                    if let productCategory = ProductCategory.fromString(product.categoryId) {
                        return productCategory == category
                    }
                    return false
                }
                print("Product '\(product.name)' with category '\(product.categoryId)' matches selected categories \(currentFilter.selectedCategories): \(categoryMatches)")
                shouldInclude = shouldInclude && categoryMatches
            }
            
            if !currentFilter.selectedColors.isEmpty {
                guard let productColors = product.colors else {
                    print("Product '\(product.name)' has no colors")
                    shouldInclude = false
                    return false
                }
                
                let productColorEnums = productColors.compactMap { ProductColor.fromString($0) }
                let hasMatchingColor = !Set(productColorEnums).isDisjoint(with: currentFilter.selectedColors)
                
                print("""
                    Product: '\(product.name)'
                    - Product colors: \(productColors)
                    - Product color enums: \(productColorEnums)
                    - Selected colors: \(currentFilter.selectedColors)
                    - Has matching color: \(hasMatchingColor)
                    """)
                
                shouldInclude = shouldInclude && hasMatchingColor
            }
            
            let price = Double(product.price)
            let isInRange = price >= currentFilter.priceRange.min && price <= currentFilter.priceRange.max
            print("Product '\(product.name)' price: \(price), range: \(currentFilter.priceRange.min)-\(currentFilter.priceRange.max), matches: \(isInRange)")
            shouldInclude = shouldInclude && isInRange
            
            if !searchQuery.isEmpty {
                let matches = product.name.lowercased().contains(searchQuery.lowercased())
                print("Product '\(product.name)' search match: \(matches) for query: '\(searchQuery)'")
                shouldInclude = shouldInclude && matches
            }
            
            return shouldInclude
        }
        
        filteredProducts = matchingProducts
        
        print("""
            === Filter Summary ===
            - Categories selected: \(currentFilter.selectedCategories)
            - Colors selected: \(currentFilter.selectedColors)
            - Price range: \(currentFilter.priceRange.min)-\(currentFilter.priceRange.max)
            - Search query: '\(searchQuery)'
            - Final product count: \(filteredProducts.count)
            ==================
            """)
        
        onProductsUpdated?()
    }
} 
