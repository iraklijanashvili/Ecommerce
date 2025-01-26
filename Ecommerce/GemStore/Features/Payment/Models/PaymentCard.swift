//
//  PaymentCard.swift
//  Ecommerce
//
//  Created by Imac on 26.01.25.
//

import Foundation
import FirebaseFirestore


struct PaymentCard: Identifiable, Codable {
    @DocumentID var id: String? = nil
    let cardNumber: String
    let cardholderName: String
    let expiryDate: String
    let cardType: CardType
    
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
}
