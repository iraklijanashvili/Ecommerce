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
    
    private static var productCache: [String: [Product]] = [:]
    
    func fetchProducts(forCollection collectionType: String) async {
        isLoading = true
        error = nil
        
        let categoryId = collectionType.replacingOccurrences(of: "_collection", with: "collection")
        
        if let cachedProducts = Self.productCache[categoryId] {
            print("Using cached products for categoryId: \(categoryId)")
            products = cachedProducts
            isLoading = false
            return
        }
        
        do {
            let snapshot = try await db.collection("products")
                .whereField("categoryId", isEqualTo: categoryId)
                .getDocuments()
            
            print("Fetching products for categoryId: \(categoryId)")
            print("Found \(snapshot.documents.count) products")
            
            let fetchedProducts = snapshot.documents.compactMap { document in
                do {
                    var data = document.data()
                    data["id"] = document.documentID
                    return try Firestore.Decoder().decode(Product.self, from: data)
                } catch {
                    print("Error decoding product: \(error)")
                    return nil
                }
            }
            
            Self.productCache[categoryId] = fetchedProducts
            products = fetchedProducts
            
        } catch {
            print("Error fetching products: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
    
    func clearCache(for categoryId: String? = nil) {
        if let categoryId = categoryId {
            Self.productCache.removeValue(forKey: categoryId)
        } else {
            Self.productCache.removeAll()
        }
    }
} 
