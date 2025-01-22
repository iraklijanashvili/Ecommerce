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
        
        let components = categoryId.components(separatedBy: "/")
        let mainCategory = components[0]
        let isAllSubcategory = components.count == 2 && components[1].lowercased() == "all"
        
        print("\n🔍 DEBUG - Category request:")
        print("- Full categoryId: \(categoryId)")
        print("- Components: \(components)")
        print("- Main category: \(mainCategory)")
        print("- Is 'all' subcategory: \(isAllSubcategory)")
        
        if isAllSubcategory {
            print("\n📦 Fetching ALL products for main category: \(mainCategory)")
            
            let query = productsRef.whereField("mainCategoryId", isEqualTo: mainCategory)
            print("- Query: mainCategoryId == \(mainCategory)")
            
            let snapshot = try await query.getDocuments()
            print("\n📝 Query results:")
            print("- Found \(snapshot.documents.count) products")
            
            let products = try snapshot.documents.map { document in
                var product = try Firestore.Decoder().decode(Product.self, from: document.data())
                product.id = document.documentID
                
                print("\n📄 Product: \(product.id)")
                print("- mainCategoryId: \(product.mainCategoryId)")
                print("- categoryId: \(product.categoryId)")
                print("- name: \(product.name)")
                
                return product
            }
            
            print("\n✅ Successfully decoded \(products.count) products")
            return products
            
        } else {
            print("\n🔍 Fetching specific subcategory: \(categoryId)")
            let query = productsRef.whereField("categoryId", isEqualTo: categoryId.lowercased())
            print("- Query: categoryId == \(categoryId.lowercased())")
            
            let snapshot = try await query.getDocuments()
            print("\n📝 Query results:")
            print("- Found \(snapshot.documents.count) products")
            
            let products = try snapshot.documents.map { document in
                var product = try Firestore.Decoder().decode(Product.self, from: document.data())
                product.id = document.documentID
                
                print("\n📄 Product: \(product.id)")
                print("- mainCategoryId: \(product.mainCategoryId)")
                print("- categoryId: \(product.categoryId)")
                print("- name: \(product.name)")
                
                return product
            }
            
            print("\n✅ Successfully decoded \(products.count) products")
            return products
        }
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
} 
