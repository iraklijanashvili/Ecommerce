//
//  FirestoreService.swift
//  Ecommerce
//
//  Created by Imac on 16.01.25.
//

import Foundation
import FirebaseFirestore

protocol FirestoreService {
    func fetchBanners() async throws -> [Banner]
    func fetchProducts() async throws -> [Product]
    func fetchCategories() async throws -> [Category]
    func getProducts(for categoryId: String) async throws -> [Product]
    func getFeaturedProducts(from products: [Product]) -> [Product]
    func getRecommendedProducts(from products: [Product]) -> [Product]
}

class FirestoreServiceImpl: FirestoreService {
    private let repository: FirestoreRepository
    private let db: Firestore
    
    init(repository: FirestoreRepository = FirestoreRepositoryImpl(), db: Firestore = Firestore.firestore()) {
        self.repository = repository
        self.db = db
    }
    
    func fetchBanners() async throws -> [Banner] {
        return try await repository.getBanners()
    }
    
    func fetchProducts() async throws -> [Product] {
        return try await repository.getProducts()
    }
    
    func fetchCategories() async throws -> [Category] {
        return try await repository.fetchCategories()
    }
    
    func getProducts(for categoryId: String) async throws -> [Product] {
        let productsRef = db.collection("products")
        let query = productsRef.whereField("categoryId", isEqualTo: categoryId)
        
        let snapshot = try await query.getDocuments()
        return try snapshot.documents.map { document in
            let data = document.data()
            var product = try Firestore.Decoder().decode(Product.self, from: data)
            product.id = document.documentID
            return product
        }
    }
    
    func getFeaturedProducts(from products: [Product]) -> [Product] {
        return products.filter { $0.isFeatured }
    }
    
    func getRecommendedProducts(from products: [Product]) -> [Product] {
        return products.filter { $0.isRecommended }
    }
} 
