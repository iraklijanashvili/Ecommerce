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
    private let filterService: ProductFilterService
    
    @Published private(set) var categories: [Category] = []
    @Published private(set) var products: [Product] = []
    @Published private(set) var filteredProducts: [Product] = []
    @Published private(set) var currentFilter = FilterOptions()
    @Published private(set) var searchQuery: String = ""
    
    var onCategoriesUpdated: (() -> Void)?
    var onProductsUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(repository: CategoryRepository = FirebaseCategoryRepository(),
         filterService: ProductFilterService = ProductFilterServiceImpl()) {
        self.repository = repository
        self.filterService = filterService
    }
    
    func fetchCategories() {
        Task {
            do {
                print("\n📂 Fetching categories...")
                categories = try await repository.fetchCategories()
                print("✅ Fetched \(categories.count) categories")
                await MainActor.run {
                    onCategoriesUpdated?()
                }
            } catch {
                print("❌ Error fetching categories: \(error)")
                await MainActor.run {
                    onError?(error)
                }
            }
        }
    }
    
    func fetchAllProducts() {
        Task {
            do {
                print("\n📦 Fetching all products...")
                let allProducts = try await repository.fetchAllProducts()
                print("✅ Fetched \(allProducts.count) products")
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.products = allProducts
                    self.applyCurrentFilter()
                }
            } catch {
                print("❌ Error fetching all products: \(error)")
                await MainActor.run { [weak self] in
                    self?.onError?(error)
                }
            }
        }
    }
    
    func fetchProducts(for categoryId: String) {
        Task {
            do {
                print("\n🔍 Fetching products for category: \(categoryId)")
                let fetchedProducts = try await repository.fetchProducts(for: categoryId)
                print("✅ Fetched \(fetchedProducts.count) products")
                
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.products = fetchedProducts
                    self.applyCurrentFilter()
                }
            } catch {
                print("❌ Error fetching products: \(error)")
                await MainActor.run { [weak self] in
                    self?.onError?(error)
                }
            }
        }
    }
    
    func search(query: String) {
        print("\n🔍 Searching with query: \(query)")
        searchQuery = query
        applyCurrentFilter()
    }
    
    func applyFilter(_ filter: FilterOptions) {
        print("\n🔧 Applying filter:")
        print("- Categories: \(filter.selectedCategories.map { $0.rawValue })")
        print("- Colors: \(filter.selectedColors.map { $0.rawValue })")
        print("- Price Range: \(filter.priceRange.min) - \(filter.priceRange.max)")
        print("- Sort By: \(filter.sortBy)")
        
        currentFilter = filter
        applyCurrentFilter()
    }
    
    func resetFilter() {
        print("\n🔄 Resetting filter")
        currentFilter = FilterOptions()
        searchQuery = ""
        filteredProducts = products
        onProductsUpdated?()
    }
    
    private func applyCurrentFilter() {
        print("\n🔍 Applying current filter to \(products.count) products")
        print("- Search Query: \(searchQuery)")
        print("- Categories: \(currentFilter.selectedCategories.map { $0.rawValue })")
        print("- Colors: \(currentFilter.selectedColors.map { $0.rawValue })")
        
        filteredProducts = filterService.filterProducts(products, with: currentFilter, searchQuery: searchQuery)
        print("✅ Filter applied - Found \(filteredProducts.count) matching products")
        
        onProductsUpdated?()
    }
} 
