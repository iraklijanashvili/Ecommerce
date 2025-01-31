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
        isLoading = true
        error = nil
        
        if let cachedProducts = Self.productCache[collectionType] {
            products = cachedProducts
            isLoading = false
            return
        }
        
        do {
            let allProducts = try await firestoreService.fetchProducts()
            
            let filteredProducts: [Product]
            if collectionType == "featured" {
                filteredProducts = firestoreService.getFeaturedProducts(from: allProducts)
            } else if collectionType == "recommended" {
                filteredProducts = firestoreService.getRecommendedProducts(from: allProducts)
            } else {
                filteredProducts = try await firestoreService.getProducts(for: collectionType)
            }
            
            Self.productCache[collectionType] = filteredProducts
            products = filteredProducts
            
        } catch {
            print("❌ Error fetching products: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
    
    func fetchProducts(forCollections collectionTypes: [String]) async {
        isLoading = true
        error = nil
        
        let cacheKey = "collections_" + collectionTypes.joined(separator: "_")
        if let cachedProducts = Self.productCache[cacheKey] {
            products = cachedProducts
            isLoading = false
            return
        }
        
        do {
            var allCollectionProducts: [Product] = []
            
            for collectionType in collectionTypes {
                let collectionProducts = try await firestoreService.getProducts(for: collectionType)
                allCollectionProducts.append(contentsOf: collectionProducts)
            }
            
            let uniqueProducts = Array(Set(allCollectionProducts))
            
            Self.productCache[cacheKey] = uniqueProducts
            products = uniqueProducts
            
        } catch {
            print("❌ Error fetching collection products: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
    
    func clearCache(for type: String? = nil) {
        if let type = type {
            Self.productCache.removeValue(forKey: type)
        } else {
            Self.productCache.removeAll()
        }
    }
} 
