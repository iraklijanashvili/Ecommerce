//
//  LoginViewModel.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import Foundation
import Combine
import UIKit

class LoginViewModel: AuthViewModel {
    
    @Published var shouldNavigateToSignUp = false
    @Published var shouldShowForgotPassword = false
    
    func login(completion: @escaping (Result<Void, Error>) -> Void) {
        guard validateInputs() else {
            completion(.failure(AuthError.invalidInput))
            return
        }
        
        isLoading = true
        authService.signIn(email: email, password: password) { [weak self] result in
            self?.isLoading = false
            completion(result)
        }
    }
    
    private func validateInputs() -> Bool {
        guard isEmailValid, isPasswordValid else {
            return false
        }
        
        guard !email.isEmpty else {
            error = AuthError.invalidEmail
            return false
        }
        
        guard !password.isEmpty else {
            error = AuthError.weakPassword
            return false
        }
        
        return true
    }
} 
