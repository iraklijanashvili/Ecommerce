//
//  AuthError.swift
//  Ecommerce
//
//  Created by Imac on 16.01.25.
//


import Foundation

public enum AuthError: LocalizedError {
    case passwordMismatch
    case invalidEmail
    case invalidPassword
    case invalidName
    case weakPassword
    case userNotFound
    case emailAlreadyInUse
    case invalidInput
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .passwordMismatch:
            return "Passwords do not match"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .invalidPassword:
            return "Please enter a valid password"
        case .invalidName:
            return "Please enter a valid name"
        case .weakPassword:
            return "Password must be at least 8 characters with 1 uppercase, 1 lowercase and 1 number"
        case .userNotFound:
            return "No user found with this email"
        case .emailAlreadyInUse:
            return "This email is already registered"
        case .invalidInput:
            return "Please check your input and try again"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
} 
