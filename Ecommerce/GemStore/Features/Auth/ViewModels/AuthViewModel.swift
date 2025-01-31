//
//  AuthViewModel.swift
//  Ecommerce
//
//  Created by Imac on 16.01.25.
//


import Foundation
import UIKit
import Combine

class AuthViewModel: ObservableObject {
    
    weak var coordinator: AuthCoordinator?
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var isEmailValid: Bool = true
    @Published var isPasswordValid: Bool = true
    
    internal let authService: AuthServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        setupValidation()
    }
    
    private func setupValidation() {
        $email
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] email in
                self?.validateEmail(email)
            }
            .store(in: &cancellables)
        
        $password
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] password in
                self?.validatePassword(password)
            }
            .store(in: &cancellables)
    }
    
    private func validateEmail(_ email: String) {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isEmailValid = emailPredicate.evaluate(with: email)
    }
    
    private func validatePassword(_ password: String) {
        isPasswordValid = password.count >= 6
    }
    
    func showSignUp() {
        coordinator?.showSignUpView()
    }
    
    func showForgotPassword() {
        coordinator?.showForgotPasswordView()
    }
    
    func finishAuth() {
        coordinator?.didFinishAuth()
    }
    
    func login() {
        isLoading = true
        authService.signIn(email: email, password: password) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.finishAuth()
            case .failure(let error):
                self?.error = error
            }
        }
    }
    
    func signUp() {
        isLoading = true
        authService.signUp(email: email, password: password, name: "", completion: { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.finishAuth()
            case .failure(let error):
                self?.error = error
            }
        })
    }
    
    func resetPassword() {
        isLoading = true
        authService.resetPassword(email: email) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.coordinator?.dismiss()
            case .failure(let error):
                self?.error = error
            }
        }
    }
    
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        authService.signInWithGoogle(presenting: viewController) { [weak self] result in
            self?.isLoading = false
            completion(result)
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !email.isEmpty else {
            completion(.failure(AuthError.invalidEmail))
            return
        }
        
        isLoading = true
        authService.resetPassword(email: email) { [weak self] result in
            self?.isLoading = false
            completion(result)
        }
    }
    
    deinit {
        cancellables.removeAll()
    }
} 
