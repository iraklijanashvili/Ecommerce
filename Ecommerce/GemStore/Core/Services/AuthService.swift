//
//  AuthService.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//



import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

protocol AuthServiceProtocol {
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signUp(email: String, password: String, name: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signInWithGoogle(presenting: UIViewController, completion: @escaping (Result<Void, Error>) -> Void)
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signOut() throws
}

class AuthService: AuthServiceProtocol {
    private let auth = Auth.auth()
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func signUp(email: String, password: String, name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(AuthError.unknown(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))))
                return
            }
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            
            changeRequest.commitChanges { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
        }
    }
    
    func signInWithGoogle(presenting: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthError.unknown(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase configuration error"]))))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(AuthError.unknown(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google Sign In failed"]))))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            self?.auth.signIn(with: credential) { result, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func signOut() throws {
        try auth.signOut()
    }
} 
