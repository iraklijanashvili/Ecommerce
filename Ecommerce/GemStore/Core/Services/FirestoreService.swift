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
    func getProducts(for categoryPath: String) async throws -> [Product]
    func getFeaturedProducts(from products: [Product]) -> [Product]
    func getRecommendedProducts(from products: [Product]) -> [Product]
    func getProducts(byIds productIds: [String]) async throws -> [Product]
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
        let batchSize = 20
        var allProducts: [Product] = []
        var lastDocument: DocumentSnapshot?
        
        repeat {
            var query = db.collection("products").limit(to: batchSize)
            if let lastDoc = lastDocument {
                query = query.start(afterDocument: lastDoc)
            }
            
            let snapshot = try await query.getDocuments()
            let products = try snapshot.documents.map { document in
                var product = try Firestore.Decoder().decode(Product.self, from: document.data())
                product.id = document.documentID
                return product
            }
            
            allProducts.append(contentsOf: products)
            lastDocument = snapshot.documents.last
            
        } while lastDocument != nil
        
        return allProducts
    }
    
    func fetchCategories() async throws -> [Category] {
        return try await repository.fetchCategories()
    }
    
    func getProducts(for categoryPath: String) async throws -> [Product] {
        if ["new_collection", "top_collection", "summer_collection"].contains(categoryPath.lowercased()) {
            print("\n🔍 Fetching collection products for: \(categoryPath)")
            let query = db.collection("products")
                .whereField("types", arrayContains: categoryPath.lowercased())
            
            let snapshot = try await query.getDocuments()
            print("\n📝 Query results:")
            print("- Found \(snapshot.documents.count) products")
            
            let products = try snapshot.documents.map { try $0.data(as: Product.self) }
            print("\n✅ Successfully decoded \(products.count) products")
            return products
        }
        
        let components = categoryPath.components(separatedBy: "/")
        let mainCategory = components[0].lowercased()
        
        if components.count > 1 {
            let subcategory = components[1].lowercased()
            print("- Subcategory: \(subcategory)")
            
            if subcategory == "all" {
                let query = db.collection("products")
                    .whereField("mainCategoryId", isEqualTo: mainCategory)
                
                let snapshot = try await query.getDocuments()
            
                let products = try snapshot.documents.map { try $0.data(as: Product.self) }
                return products
            } else {
                
                let query = db.collection("products")
                    .whereField("mainCategoryId", isEqualTo: mainCategory)
                    .whereField("categoryId", isEqualTo: subcategory)
                
                let snapshot = try await query.getDocuments()
                
                let products = try snapshot.documents.map { try $0.data(as: Product.self) }
                print("✅ Successfully decoded \(products.count) products")
                return products
            }
        }
        
      
        let query = db.collection("products")
            .whereField("mainCategoryId", isEqualTo: mainCategory)
        
        let snapshot = try await query.getDocuments()
        let products = try snapshot.documents.map { try $0.data(as: Product.self) }
        return products
    }
    
    private func getSubcategoryIds(for categoryId: String) -> [String] {
        switch categoryId {
        case "clothing":
            return ["jackets", "dresses", "hoodie"]
        case "shoes":
            return ["athletic Shoes", "casual Shoes"]
        case "accessories":
            return ["bags", "Jewelry"]
        case "collection":
            return ["newcollection", "topcollection", "summercollection"]
        default:
            return []
        }
    }
    
    func getFeaturedProducts(from products: [Product]) -> [Product] {
        return products.filter { $0.isFeatured }
    }
    
    func getRecommendedProducts(from products: [Product]) -> [Product] {
        return products.filter { $0.isRecommended }
    }
    
    func getProducts(byIds productIds: [String]) async throws -> [Product] {
        guard !productIds.isEmpty else { return [] }
        
        let chunkedIds = stride(from: 0, to: productIds.count, by: 10).map {
            Array(productIds[$0..<min($0 + 10, productIds.count)])
        }
        
        var allProducts: [Product] = []
        
        for chunk in chunkedIds {
            let snapshot = try await db.collection("products")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments()
            
            let products = snapshot.documents.compactMap { document -> Product? in
                try? document.data(as: Product.self)
            }
            
            allProducts.append(contentsOf: products)
        }
        
        return allProducts
    }
} 
