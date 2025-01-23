//
//  FavoritesService.swift
//  Ecommerce
//
//  Created by Imac on 21.01.25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

protocol FavoritesService {
    func addFavorite(product: Product) async throws
    func removeFavorite(productId: String) async throws
    func isFavorite(productId: String) async throws -> Bool
    func getFavorites() async throws -> [Product]
    var favoritesPublisher: AnyPublisher<[Product], Never> { get }
}

class FavoritesServiceImpl: FavoritesService {
    static let shared = FavoritesServiceImpl()
    
    private let db = Firestore.firestore()
    private let firestoreService: FirestoreService
    private var favoritesSubject = CurrentValueSubject<[Product], Never>([])
    
    var favoritesPublisher: AnyPublisher<[Product], Never> {
        favoritesSubject.eraseToAnyPublisher()
    }
    
    private init(firestoreService: FirestoreService = FirestoreServiceImpl()) {
        self.firestoreService = firestoreService
        startObservingFavorites()
    }
    
    private func startObservingFavorites() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("userFavorites")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self,
                      let snapshot = snapshot else { return }
                
                Task {
                    let productIds = snapshot.documents.compactMap { doc -> String? in
                        guard let favorite = UserFavorite.from(doc) else { return nil }
                        return favorite.productId
                    }
                    
                    let products = try? await self.firestoreService.getProducts(byIds: productIds)
                    self.favoritesSubject.send(products ?? [])
                }
            }
    }
    
    func addFavorite(product: Product) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FavoritesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        let favorite = UserFavorite(
            userId: userId,
            productId: product.id,
            addedAt: Date()
        )
        
        try await db.collection("userFavorites").document("\(userId)_\(product.id)").setData(favorite.firestoreData)
    }
    
    func removeFavorite(productId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FavoritesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        try await db.collection("userFavorites").document("\(userId)_\(productId)").delete()
    }
    
    func isFavorite(productId: String) async throws -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        
        let docRef = db.collection("userFavorites").document("\(userId)_\(productId)")
        let doc = try await docRef.getDocument()
        return doc.exists
    }
    
    func getFavorites() async throws -> [Product] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await db.collection("userFavorites")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        let productIds = snapshot.documents.compactMap { doc -> String? in
            guard let favorite = UserFavorite.from(doc) else { return nil }
            return favorite.productId
        }
        
        return try await firestoreService.getProducts(byIds: productIds)
    }
}
