//
//  AddCardViewModel.swift
//  Ecommerce
//
//  Created by Imac on 26.01.25.
//

import Foundation
import Combine

@MainActor
class AddCardViewModel: ObservableObject {
    @Published var cardNumber = ""
    @Published var formattedCardNumber = ""
    @Published var cardholderName = ""
    @Published var expiryDate = ""
    @Published var cvv = ""
    @Published var showingError = false
    @Published var errorMessage = ""
    
    private let parentViewModel: PaymentViewModel
    
    init(parentViewModel: PaymentViewModel) {
        self.parentViewModel = parentViewModel
    }
    
    var isAmex: Bool {
        cardNumber.hasPrefix("34") || cardNumber.hasPrefix("37")
    }
    
    var isFormValid: Bool {
        let cardNumberValid = cardNumber.count >= (isAmex ? 15 : 16)
        let nameValid = cardholderName.count >= 2
        let expiryValid = expiryDate.count == 5
        let cvvValid = cvv.count == (isAmex ? 4 : 3)
        
        return cardNumberValid && nameValid && expiryValid && cvvValid
    }
    
    func formatCardNumber(_ number: String) {
        let filtered = number.filter { $0.isNumber }
        cardNumber = filtered
        
        if filtered.count <= 16 {
            var formatted = ""
            for (index, char) in filtered.enumerated() {
                if index > 0 && index % 4 == 0 {
                    formatted += " "
                }
                formatted += String(char)
            }
            if formatted != formattedCardNumber {
                formattedCardNumber = formatted
            }
        } else {
            formattedCardNumber = String(formattedCardNumber.prefix(19))
        }
    }
    
    func formatExpiryDate(_ input: String) {
        let filtered = input.filter { $0.isNumber }
        if filtered.count <= 4 {
            var formatted = ""
            for (index, char) in filtered.enumerated() {
                if index == 2 { formatted += "/" }
                formatted += String(char)
            }
            if formatted != expiryDate {
                expiryDate = formatted
            }
        } else {
            expiryDate = String(expiryDate.prefix(5))
        }
    }
    
    func formatCVV(_ input: String) {
        let filtered = input.filter { $0.isNumber }
        cvv = String(filtered.prefix(isAmex ? 4 : 3))
    }
    
    func validateCardholderName(_ input: String) -> Bool {
        let containsOnlyLettersAndSpaces = input.range(of: "[^a-zA-Z\\s]", options: .regularExpression) == nil
        return containsOnlyLettersAndSpaces && input.count >= 2
    }
    
    func formatCardholderName(_ input: String) {
        if validateCardholderName(input) {
            cardholderName = input
        }
    }
    
    func validateCard() -> Bool {
        guard validateCardholderName(cardholderName) else {
            showError("Cardholder name should only contain letters")
            return false
        }
        
        let numbers = cardNumber.compactMap { Int(String($0)) }
        guard numbers.count == (isAmex ? 15 : 16) else {
            showError("Invalid card number length")
            return false
        }
        
        let components = expiryDate.split(separator: "/")
        guard components.count == 2,
              let month = Int(components[0]),
              let year = Int(components[1]),
              month >= 1 && month <= 12 else {
            showError("Invalid expiry date")
            return false
        }
        
        let currentYear = Calendar.current.component(.year, from: Date()) % 100
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        if year < currentYear || (year == currentYear && month < currentMonth) {
            showError("Card has expired")
            return false
        }
        
        return true
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
    
    func addCard() async {
        guard validateCard() else { return }
        
        let card = PaymentCard(
            cardNumber: cardNumber.filter { $0.isNumber },
            cardholderName: cardholderName,
            expiryDate: expiryDate,
            cardType: PaymentCard.detectCardType(from: cardNumber)
        )
        
        await parentViewModel.addCard(card)
    }
} 
