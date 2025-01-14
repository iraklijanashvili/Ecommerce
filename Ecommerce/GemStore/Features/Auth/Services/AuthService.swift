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

enum AuthError: LocalizedError {
    case passwordMismatch
    case invalidEmail
    case weakPassword
    case userNotFound
    case emailAlreadyInUse
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .passwordMismatch:
            return "Passwords do not match"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 8 characters with 1 uppercase, 1 lowercase and 1 number"
        case .userNotFound:
            return "No user found with this email"
        case .emailAlreadyInUse:
            return "This email is already registered"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

protocol AuthServiceProtocol {
    func signUp(email: String, password: String, name: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<Void, Error>) -> Void)
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signOut() throws
    func sendSignInLink(to email: String, completion: @escaping (Result<Void, Error>) -> Void)
    func isSignInWithEmailLink(_ link: String) -> Bool
    func signInWithEmailLink(email: String, link: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class AuthService: NSObject, AuthServiceProtocol {
    
    private let auth = Auth.auth()
    
    func signUp(email: String, password: String, name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                let authError = self?.handleFirebaseError(error)
                completion(.failure(authError ?? error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(AuthError.unknown(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]))))
                return
            }
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { error in
                if let error = error {
                    completion(.failure(AuthError.unknown(error)))
                    return
                }
                completion(.success(()))
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                let authError = self?.handleFirebaseError(error)
                completion(.failure(authError ?? error))
                return
            }
            completion(.success(()))
        }
    }
    
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [weak self] result, error in
            if let error = error {
                completion(.failure(AuthError.unknown(error)))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(AuthError.unknown(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user info from Google"]))))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            self?.auth.signIn(with: credential) { result, error in
                if let error = error {
                    completion(.failure(AuthError.unknown(error)))
                    return
                }
                completion(.success(()))
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(AuthError.unknown(error)))
                return
            }
            completion(.success(()))
        }
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func sendSignInLink(to email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://your-app-domain.example.com")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
            if let error = error {
                completion(.failure(AuthError.unknown(error)))
                return
            }
            UserDefaults.standard.set(email, forKey: "EmailForSignIn")
            completion(.success(()))
        }
    }
    
    func isSignInWithEmailLink(_ link: String) -> Bool {
        return Auth.auth().isSignIn(withEmailLink: link)
    }
    
    func signInWithEmailLink(email: String, link: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, link: link) { result, error in
            if let error = error {
                completion(.failure(AuthError.unknown(error)))
                return
            }
            completion(.success(()))
        }
    }
    
    private func handleFirebaseError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return .unknown(error)
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.weakPassword.rawValue:
            return .weakPassword
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
        default:
            return .unknown(error)
        }
    }
} 
