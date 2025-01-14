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

class LoginViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome\nBack"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email address"
        textField.borderStyle = .none
        textField.keyboardType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("LOG IN", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "or login with"
        label.textColor = .gray
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
    
    private let signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't have an account? Sign Up"
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        
        let text = label.text ?? ""
        let attributedString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: "Sign Up")
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        label.attributedText = attributedString
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupBindings()
    }
    
    private func setupBindings() {
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange), for: .editingChanged)
    }
    
    @objc private func emailTextFieldDidChange() {
        viewModel.email = emailTextField.text ?? ""
    }
    
    @objc private func passwordTextFieldDidChange() {
        viewModel.password = passwordTextField.text ?? ""
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        titleLabel.textColor = .black
        emailTextField.textColor = .black
        passwordTextField.textColor = .black
        signUpLabel.textColor = .black
        
        [emailTextField, passwordTextField].forEach { textField in
            textField.attributedPlaceholder = NSAttributedString(
                string: textField.placeholder ?? "",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            )
        }
        
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(forgotPasswordButton)
        view.addSubview(loginButton)
        view.addSubview(orLabel)
        view.addSubview(socialButtonsStackView)
        view.addSubview(signUpLabel)
        
        socialButtonsStackView.addArrangedSubview(googleButton)
        
        setupGoogleButton()
        setupConstraints()
        setupTextFieldsUnderlines()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            
            loginButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 220),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            orLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            orLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            socialButtonsStackView.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 20),
            socialButtonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            socialButtonsStackView.heightAnchor.constraint(equalToConstant: 50),
            
            signUpLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            signUpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTextFieldsUnderlines() {
        [emailTextField, passwordTextField].forEach { textField in
            let underlineView = UIView()
            underlineView.backgroundColor = .lightGray
            underlineView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(underlineView)
            
            NSLayoutConstraint.activate([
                underlineView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
                underlineView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
                underlineView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 5),
                underlineView.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        
        let signUpTapGesture = UITapGestureRecognizer(target: self, action: #selector(signUpLabelTapped))
        signUpLabel.addGestureRecognizer(signUpTapGesture)
    }
    
    @objc private func loginButtonTapped() {
        viewModel.login()
    }
    
    @objc private func googleSignInTapped() {
        viewModel.signInWithGoogle(presenting: self)
    }
    
    @objc private func signUpLabelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func forgotPasswordTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter your email address", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        viewModel.resetPassword(email: email)
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
}

extension LoginViewController: LoginViewModelDelegate {
    func didLoginSuccessfully() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    func didFailLogin(with error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func didSendResetPasswordEmail() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Success",
                message: "Password reset instructions have been sent to your email",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

struct LoginViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LoginViewController {
        let vc = LoginViewController()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: LoginViewController, context: Context) {
    }
}
    
