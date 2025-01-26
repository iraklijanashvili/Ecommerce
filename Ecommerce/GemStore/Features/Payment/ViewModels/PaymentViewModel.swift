
//
//  PaymentViewModel.swift
//  Ecommerce
//
//  Created by Imac on 26.01.25.
//

import Foundation
import Combine

class PaymentViewModel: ObservableObject {
    @Published var cards: [PaymentCard] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showAddCard = false
    
    private let paymentService: PaymentServiceProtocol
    
    init(paymentService: PaymentServiceProtocol = PaymentServiceImpl.shared) {
        self.paymentService = paymentService
        Task {
            await loadCards()
        }
    }
    
    @MainActor
    func loadCards() async {
        isLoading = true
        do {
            cards = try await paymentService.fetchCards()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    @MainActor
    func addCard(_ card: PaymentCard) async {
        isLoading = true
        do {
            try await paymentService.addCard(card)
            await loadCards()
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    @MainActor
    func deleteCard(id: String) async {
        if let index = cards.firstIndex(where: { $0.id == id }) {
            cards.remove(at: index)
        }
        
        do {
            try await paymentService.deleteCard(id: id)
        } catch {
            errorMessage = error.localizedDescription
            await loadCards()
        }
    }
} 
