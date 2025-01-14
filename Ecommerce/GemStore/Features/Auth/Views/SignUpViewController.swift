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
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let googleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "google"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        return button
    }()
    
    private let facebookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "facebook"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        return button
    }()
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "Already have account? Log In"
        label.textColor = .black
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var viewModel: SignUpViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupViewModel()
        setupKeyboardHandling()
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
        socialButtonsStackView.addArrangedSubview(facebookButton)
        
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
            signUpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            orLabel.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20),
            orLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            socialButtonsStackView.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 20),
            socialButtonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            socialButtonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
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
    
    private func setupActions() {
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        
        let loginTapGesture = UITapGestureRecognizer(target: self, action: #selector(loginLabelTapped))
        loginLabel.addGestureRecognizer(loginTapGesture)
    }
    
    private func setupViewModel() {
        viewModel = SignUpViewModel()
        viewModel.delegate = self
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func signUpButtonTapped() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              let name = nameTextField.text else { return }
        
        viewModel.signUp(email: email, password: password, confirmPassword: confirmPassword, name: name)
    }
    
    @objc private func googleSignInTapped() {
        viewModel.signInWithGoogle(presenting: self)
    }
    
    @objc private func loginLabelTapped() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
    }
}

extension SignUpViewController: SignUpViewModelDelegate {
    func didSignUpSuccessfully() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    func didFailSignUp(with error: Error) {
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
