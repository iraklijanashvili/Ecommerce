//
//  ServiceProtocols.swift
//  Ecommerce
//
//  Created by Imac on 24.01.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol UserServiceProtocol {
    var currentUser: User? { get }
}

struct User {
    let firstName: String
    let lastName: String
    
    static func fromFirebaseUser(_ firebaseUser: FirebaseAuth.User?) -> User? {
        guard let displayName = firebaseUser?.displayName else { return nil }
        let components = displayName.components(separatedBy: " ")
        let firstName = components.first ?? ""
        let lastName = components.dropFirst().joined(separator: " ")
        return User(firstName: firstName, lastName: lastName)
    }
}

class UserService: UserServiceProtocol {
    private let db = Firestore.firestore()
    
    var currentUser: User? {
        get {
            if let user = User.fromFirebaseUser(Auth.auth().currentUser) {
                return user
            }
            
            guard let userId = Auth.auth().currentUser?.uid else { return nil }
            
            let semaphore = DispatchSemaphore(value: 0)
            var user: User?
            
            db.collection("users").document(userId).getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    user = User(
                        firstName: data["firstName"] as? String ?? "",
                        lastName: data["lastName"] as? String ?? ""
                    )
                }
                semaphore.signal()
            }
            
            _ = semaphore.wait(timeout: .now() + 2)
            return user
        }
    }
} 
