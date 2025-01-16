//
//  ProfileViewModel.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import Foundation
import FirebaseAuth
import Combine

struct UserProfile {
    let id: String
    let email: String?
    let name: String?
    let photoURL: URL?
}

class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        fetchUserProfile()
    }
    
    func fetchUserProfile() {
        isLoading = true
        if let user = Auth.auth().currentUser {
            userProfile = UserProfile(
                id: user.uid,
                email: user.email,
                name: user.displayName,
                photoURL: user.photoURL
            )
        }
        isLoading = false
    }
    
    func signOut() {
        do {
            try authService.signOut()
        } catch {
            self.error = error
        }
    }
    
    func updateProfile(name: String) {
        isLoading = true
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        
        changeRequest?.commitChanges { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.error = error
                } else {
                    self?.fetchUserProfile()
                }
            }
        }
    }
} 
