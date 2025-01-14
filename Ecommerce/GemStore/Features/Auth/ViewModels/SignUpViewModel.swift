//
//  SignUpViewModel.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//


import Foundation
import FirebaseAuth
import GoogleSignIn

protocol SignUpViewModelDelegate: AnyObject {
    func didSignUpSuccessfully()
    func didFailSignUp(with error: Error)
}

class SignUpViewModel {
    
    private let authService: AuthServiceProtocol
    weak var delegate: SignUpViewModelDelegate?
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    func signUp(email: String, password: String, confirmPassword: String, name: String) {
        guard password == confirmPassword else {
            delegate?.didFailSignUp(with: AuthError.passwordMismatch)
            return
        }
        
        guard isValidEmail(email) else {
            delegate?.didFailSignUp(with: AuthError.invalidEmail)
            return
        }
        
        guard isValidPassword(password) else {
            delegate?.didFailSignUp(with: AuthError.weakPassword)
            return
        }
        
        authService.signUp(email: email, password: password, name: name) { [weak self] result in
            switch result {
            case .success:
                self?.delegate?.didSignUpSuccessfully()
            case .failure(let error):
                self?.delegate?.didFailSignUp(with: error)
            }
        }
    }
    
    func signInWithGoogle(presenting viewController: UIViewController) {
        authService.signInWithGoogle(presenting: viewController) { [weak self] result in
            switch result {
            case .success:
                self?.delegate?.didSignUpSuccessfully()
            case .failure(let error):
                self?.delegate?.didFailSignUp(with: error)
            }
        }
    }
    
    func sendSignInLink(email: String) {
        guard isValidEmail(email) else {
            delegate?.didFailSignUp(with: AuthError.invalidEmail)
            return
        }
        
        authService.sendSignInLink(to: email) { [weak self] result in
            switch result {
            case .success:
                self?.delegate?.didSignUpSuccessfully()
            case .failure(let error):
                self?.delegate?.didFailSignUp(with: error)
            }
        }
    }
    
    func handleEmailLink(_ link: String) {
        guard authService.isSignInWithEmailLink(link),
              let email = UserDefaults.standard.string(forKey: "EmailForSignIn") else {
            delegate?.didFailSignUp(with: AuthError.unknown(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid email link"])))
            return
        }
        
        authService.signInWithEmailLink(email: email, link: link) { [weak self] result in
            switch result {
            case .success:
                UserDefaults.standard.removeObject(forKey: "EmailForSignIn")
                self?.delegate?.didSignUpSuccessfully()
            case .failure(let error):
                self?.delegate?.didFailSignUp(with: error)
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
} 
