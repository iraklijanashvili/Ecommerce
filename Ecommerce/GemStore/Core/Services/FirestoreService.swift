//
//  FirestoreService.swift
//  Ecommerce
//
//  Created by Imac on 16.01.25.
//

import Foundation

protocol FirestoreService {
    func fetchBanners() async throws -> [Banner]
    func fetchProducts() async throws -> [Product]
    func getFeaturedProducts(from products: [Product]) -> [Product]
    func getRecommendedProducts(from products: [Product]) -> [Product]
}

class FirestoreServiceImpl: FirestoreService {
    private let repository: FirestoreRepository
    
    init(repository: FirestoreRepository = FirestoreRepositoryImpl()) {
        self.repository = repository
    }
    
    func fetchBanners() async throws -> [Banner] {
        return try await repository.getBanners()
    }
    
    func fetchProducts() async throws -> [Product] {
        return try await repository.getProducts()
    }
    
    func getFeaturedProducts(from products: [Product]) -> [Product] {
        return products.filter { $0.types.contains(.featured) }
    }
    
    func getRecommendedProducts(from products: [Product]) -> [Product] {
        return products.filter { $0.types.contains(.recommended) }
    }
} 
