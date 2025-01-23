//
//  UserFavorite.swift
//  Ecommerce
//
//  Created by Imac on 23.01.25.
//

import Foundation
import FirebaseFirestore

struct UserFavorite: Codable {
    let userId: String
    let productId: String
    let addedAt: Date
    
    var firestoreData: [String: Any] {
        return [
            "userId": userId,
            "productId": productId,
            "addedAt": Timestamp(date: addedAt)
        ]
    }
    
    static func from(_ document: QueryDocumentSnapshot) -> UserFavorite? {
        guard 
            let userId = document.data()["userId"] as? String,
            let productId = document.data()["productId"] as? String,
            let timestamp = document.data()["addedAt"] as? Timestamp
        else { return nil }
        
        return UserFavorite(
            userId: userId,
            productId: productId,
            addedAt: timestamp.dateValue()
        )
    }
} 
