//
//  PaymentCard.swift
//  Ecommerce
//
//  Created by Imac on 26.01.25.
//

import Foundation
import FirebaseFirestore

struct PaymentCard: Identifiable, Codable, Equatable {
    @DocumentID var id: String? = nil
    let cardNumber: String
    let cardholderName: String
    let expiryDate: String
    let cardType: CardType
    
    static func == (lhs: PaymentCard, rhs: PaymentCard) -> Bool {
        lhs.id == rhs.id &&
        lhs.cardNumber == rhs.cardNumber &&
        lhs.cardholderName == rhs.cardholderName &&
        lhs.expiryDate == rhs.expiryDate &&
        lhs.cardType == rhs.cardType
    }
    
    enum CardType: String, Codable {
        case visa = "visa"
        case mastercard = "mastercard"
        case amex = "amex"
        
        static func fromString(_ value: String) -> CardType? {
            return CardType(rawValue: value.lowercased())
        }
    }
    
    static func detectCardType(from number: String) -> CardType {
        let cleanNumber = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        switch cleanNumber.prefix(1) {
        case "4":
            return .visa
        case "5":
            return .mastercard
        case "3" where cleanNumber.prefix(2) == "34" || cleanNumber.prefix(2) == "37":
            return .amex
        default:
            return .visa
        }
    }
    
    var maskedNumber: String {
        let lastFourDigits = String(cardNumber.suffix(4))
        return "•••• •••• •••• \(lastFourDigits)"
    }
}

enum CardType: String, Codable {
    case visa
    case mastercard
    case amex
    case unknown
    
    var icon: String {
        switch self {
        case .visa:
            return "visa"
        case .mastercard:
            return "mastercard"
        case .amex:
            return "amex"
        case .unknown:
            return "creditcard"
        }
    }
}
