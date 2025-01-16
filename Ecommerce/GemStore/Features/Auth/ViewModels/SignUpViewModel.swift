//
//  SignUpViewModel.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//


import Foundation
import Combine
import UIKit

class SignUpViewModel: AuthViewModel {
    @Published var name: String = ""
    @Published var confirmPassword: String = ""
    @Published var isNameValid: Bool = true
    @Published var isConfirmPasswordValid: Bool = true
    @Published var shouldNavigateToLogin = false
    
    private var additionalCancellables = Set<AnyCancellable>()
    
    override init(authService: AuthServiceProtocol = AuthService()) {
        super.init(authService: authService)
        setupAdditionalValidation()
    }
    
    private func setupAdditionalValidation() {
        $name
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] name in
                self?.validateName(name)
            }
            .store(in: &additionalCancellables)
        
        $confirmPassword
            .combineLatest($password)
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] confirmPassword, password in
                self?.validateConfirmPassword(confirmPassword, password: password)
            }
            .store(in: &additionalCancellables)
    }
    
    private func validateName(_ name: String) {
        isNameValid = name.count >= 2
    }
    
    private func validateConfirmPassword(_ confirmPassword: String, password: String) {
        isConfirmPasswordValid = confirmPassword == password
    }
    
    private func validateInputs() -> Bool {
        guard isEmailValid, isPasswordValid, isNameValid, isConfirmPasswordValid else {
            return false
        }
        
        guard !name.isEmpty else {
            error = AuthError.invalidName
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
        
        guard password == confirmPassword else {
            error = AuthError.passwordMismatch
            return false
        }
        
        return true
    }
    
    func signUp(completion: @escaping (Result<Void, Error>) -> Void) {
        guard validateInputs() else {
            completion(.failure(AuthError.invalidInput))
            return
        }
        
        isLoading = true
        authService.signUp(email: email, password: password, name: name) { [weak self] result in
            self?.isLoading = false
            completion(result)
        }
    }
} 
