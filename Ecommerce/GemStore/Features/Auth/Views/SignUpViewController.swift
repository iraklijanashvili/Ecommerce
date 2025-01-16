//
//  SignUpViewController.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//


import UIKit
import FirebaseAuth
import GoogleSignIn
import SwiftUI
import Combine

class SignUpViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create\nyour account"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.numberOfLines = 2
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your name"
        textField.borderStyle = .none
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email address"
        textField.borderStyle = .none
        textField.keyboardType = .emailAddress
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm password"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SIGN UP", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "or sign up with"
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let socialButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let googleButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let googleIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "GoogleIcon")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let googleSignInLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in with Google"
        label.textColor = .black
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "Already have account? Log In"
        label.textColor = .black
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        
        let text = label.text ?? ""
        let attributedString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: "Log In")
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        label.attributedText = attributedString
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewModel: SignUpViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: SignUpViewModel = SignUpViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField].forEach { textField in
            textField.attributedPlaceholder = NSAttributedString(
                string: textField.placeholder ?? "",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            )
        }
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(confirmPasswordTextField)
        contentView.addSubview(signUpButton)
        contentView.addSubview(orLabel)
        contentView.addSubview(socialButtonsStackView)
        view.addSubview(loginLabel)
        
        socialButtonsStackView.addArrangedSubview(googleButton)
        
        setupGoogleButton()
        setupConstraints()
        setupTextFieldsUnderlines()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: loginLabel.topAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            signUpButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 40),
            signUpButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signUpButton.widthAnchor.constraint(equalToConstant: 220),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            orLabel.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20),
            orLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            socialButtonsStackView.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 20),
            socialButtonsStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            socialButtonsStackView.heightAnchor.constraint(equalToConstant: 50),
            socialButtonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            loginLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            loginLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTextFieldsUnderlines() {
        [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField].forEach { textField in
            let underlineView = UIView()
            underlineView.backgroundColor = .lightGray
            underlineView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(underlineView)
            
            NSLayoutConstraint.activate([
                underlineView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
                underlineView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
                underlineView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 5),
                underlineView.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    }
    
    private func setupBindings() {
        nameTextField.textPublisher
            .assign(to: \.name, on: viewModel)
            .store(in: &cancellables)
        
        emailTextField.textPublisher
            .assign(to: \.email, on: viewModel)
            .store(in: &cancellables)
        
        passwordTextField.textPublisher
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)
        
        confirmPasswordTextField.textPublisher
            .assign(to: \.confirmPassword, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.signUpButton.isEnabled = !isLoading
                self?.signUpButton.alpha = isLoading ? 0.5 : 1
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
        
        viewModel.$isNameValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.nameTextField.textColor = isValid ? .black : .red
            }
            .store(in: &cancellables)
        
        viewModel.$isEmailValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.emailTextField.textColor = isValid ? .black : .red
            }
            .store(in: &cancellables)
        
        viewModel.$isPasswordValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.passwordTextField.textColor = isValid ? .black : .red
            }
            .store(in: &cancellables)
        
        viewModel.$isConfirmPasswordValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.confirmPasswordTextField.textColor = isValid ? .black : .red
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        
        let loginTapGesture = UITapGestureRecognizer(target: self, action: #selector(loginLabelTapped))
        loginLabel.addGestureRecognizer(loginTapGesture)
    }
    
    @objc private func signUpButtonTapped() {
        viewModel.signUp { [weak self] result in
            switch result {
            case .success:
                self?.dismiss(animated: true)
            case .failure(let error):
                self?.showError(error)
            }
        }
    }
    
    @objc private func googleSignInTapped() {
        viewModel.signInWithGoogle(presenting: self) { [weak self] result in
            switch result {
            case .success:
                self?.dismiss(animated: true)
            case .failure(let error):
                self?.showError(error)
            }
        }
    }
    
    @objc private func loginLabelTapped() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
    }
    
    private func setupGoogleButton() {
        googleButton.addSubview(googleIconImageView)
        googleButton.addSubview(googleSignInLabel)
        
        NSLayoutConstraint.activate([
            googleButton.heightAnchor.constraint(equalToConstant: 50),
            googleButton.widthAnchor.constraint(equalToConstant: 220),
            
            googleIconImageView.leadingAnchor.constraint(equalTo: googleButton.leadingAnchor, constant: 20),
            googleIconImageView.centerYAnchor.constraint(equalTo: googleButton.centerYAnchor),
            googleIconImageView.widthAnchor.constraint(equalToConstant: 24),
            googleIconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            googleSignInLabel.centerYAnchor.constraint(equalTo: googleButton.centerYAnchor),
            googleSignInLabel.centerXAnchor.constraint(equalTo: googleButton.centerXAnchor, constant: 10)
        ])
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

struct SignUpViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SignUpViewController {
        let vc = SignUpViewController()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SignUpViewController, context: Context) {
    }
}
