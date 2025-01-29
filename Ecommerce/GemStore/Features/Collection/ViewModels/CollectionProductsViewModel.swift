//
//  CollectionProductsViewModel.swift
//  Ecommerce
//
//  Created by Imac on 22.01.25.
//

import Foundation
import FirebaseFirestore

@MainActor
class CollectionProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    private let firestoreService: FirestoreService
    
    private static var productCache: [String: [Product]] = [:]
    
    init(firestoreService: FirestoreService = FirestoreServiceImpl()) {
        self.firestoreService = firestoreService
    }
    
    func fetchProducts(forCollection collectionType: String) async {
        print("🔍 Starting to fetch products for collectionType: \(collectionType)")
        isLoading = true
        error = nil
        
        if let cachedProducts = Self.productCache[collectionType] {
            print("📦 Using cached products for type: \(collectionType), count: \(cachedProducts.count)")
            products = cachedProducts
            isLoading = false
            return
        }
        
        do {
            let allProducts = try await firestoreService.fetchProducts()
            print("📥 Fetched \(allProducts.count) total products")
            
            let filteredProducts: [Product]
            if collectionType == "featured" {
                print("🏷 Filtering featured products")
                filteredProducts = firestoreService.getFeaturedProducts(from: allProducts)
            } else if collectionType == "recommended" {
                print("🏷 Filtering recommended products")
                filteredProducts = firestoreService.getRecommendedProducts(from: allProducts)
            } else {
                print("📁 Getting products for category: \(collectionType)")
                filteredProducts = try await firestoreService.getProducts(for: collectionType)
            }
            
            print("✅ Found \(filteredProducts.count) products for \(collectionType)")
            Self.productCache[collectionType] = filteredProducts
            products = filteredProducts
            
        } catch {
            print("❌ Error fetching products: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
    
    func clearCache(for type: String? = nil) {
        if let type = type {
            Self.productCache.removeValue(forKey: type)
            print("🗑 Cleared cache for type: \(type)")
        } else {
            Self.productCache.removeAll()
            print("🗑 Cleared all cache")
        }
    }
} 
