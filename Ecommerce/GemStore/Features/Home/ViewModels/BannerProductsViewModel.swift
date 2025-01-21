//
//  BannerProductsViewModel.swift
//  Ecommerce
//
//  Created by Imac on 22.01.25.
//


import Foundation
import FirebaseFirestore

class BannerProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let firestoreService = FirestoreServiceImpl()
    private let db = Firestore.firestore()
    
    func fetchProducts(forCollection collectionType: String) async {
        isLoading = true
        error = nil
        
        do {
            let snapshot = try await db.collection("products")
                .whereField("collectionType", isEqualTo: collectionType)
                .getDocuments()
            
            products = snapshot.documents.compactMap { document in
                try? document.data(as: Product.self)
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
} 
