import Foundation
import Combine
import UIKit

protocol LoginViewModelDelegate: AnyObject {
    func didLoginSuccessfully()
    func didFailLogin(with error: Error)
}

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let authService: AuthServiceProtocol
    weak var delegate: LoginViewModelDelegate?
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            delegate?.didFailLogin(with: AuthError.invalidEmail)
            return
        }
        
        isLoading = true
        authService.signIn(email: email, password: password) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.delegate?.didLoginSuccessfully()
            case .failure(let error):
                self?.error = error
                self?.delegate?.didFailLogin(with: error)
            }
        }
    }
    
    func signInWithGoogle(presenting viewController: UIViewController) {
        isLoading = true
        authService.signInWithGoogle(presenting: viewController) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.delegate?.didLoginSuccessfully()
            case .failure(let error):
                self?.error = error
                self?.delegate?.didFailLogin(with: error)
            }
        }
    }
    
    func validateInput() -> Bool {
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