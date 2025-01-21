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
    
    func fetchProducts(forCollection collectionType: String) async {
        isLoading = true
        error = nil
        
        do {
            let categoryId = collectionType.replacingOccurrences(of: "_collection", with: "collection")
            
            let snapshot = try await db.collection("products")
                .whereField("categoryId", isEqualTo: categoryId)
                .getDocuments()
            
            print("Fetching products for categoryId: \(categoryId)")
            print("Found \(snapshot.documents.count) products")
            
            products = snapshot.documents.compactMap { document in
                do {
                    var data = document.data()
                    data["id"] = document.documentID
                    return try Firestore.Decoder().decode(Product.self, from: data)
                } catch {
                    print("Error decoding product: \(error)")
                    return nil
                }
            }
        } catch {
            print("Error fetching products: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
} 
