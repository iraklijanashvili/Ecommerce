//
//  PaymentService.swift
//  Ecommerce
//
//  Created by Imac on 26.01.25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol PaymentServiceProtocol {
    func fetchCards() async throws -> [PaymentCard]
    func addCard(_ card: PaymentCard) async throws
    func deleteCard(id: String) async throws
}

class PaymentServiceImpl: PaymentServiceProtocol {
    static let shared = PaymentServiceImpl()
    private let db = Firestore.firestore()
    
    private var userCardsRef: CollectionReference? {
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(userId).collection("cards")
    }
    
    func fetchCards() async throws -> [PaymentCard] {
        guard let userCardsRef = userCardsRef else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let snapshot = try await userCardsRef.getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: PaymentCard.self)
        }
    }
    
    func addCard(_ card: PaymentCard) async throws {
        guard let userCardsRef = userCardsRef else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let docRef = userCardsRef.document()
        var updatedCard = card
        updatedCard.id = docRef.documentID
        try docRef.setData(from: updatedCard)
    }
    
    func deleteCard(id: String) async throws {
        guard let userCardsRef = userCardsRef else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        try await userCardsRef.document(id).delete()
    }
}
