//
//  PaymentView.swift
//  Ecommerce
//
//  Created by Imac on 26.01.25.
//

import SwiftUI
import FirebaseFirestore

struct PaymentView: View {
    @StateObject private var viewModel = PaymentViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var cardLogos: [String: String] = [:]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    cardManagementSection
                }
                .padding(.vertical)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitle("Payment", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.black)
        })
        .sheet(isPresented: $viewModel.showAddCard) {
            AddCardView(parentViewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .onAppear {
            fetchCardLogos()
        }
    }
    
    private func fetchCardLogos() {
        let db = Firestore.firestore()
        let cardTypes = ["visa", "mastercard", "amex"]
        
        for cardType in cardTypes {
            let docRef = db.collection("cardLogos").document(cardType)
            docRef.getDocument { document, error in
                if let document = document, document.exists {
                    if let logoUrl = document.data()?["logoUrl"] as? String {
                        cardLogos[cardType] = logoUrl
                    }
                }
            }
        }
    }

    private var cardManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Card Management")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button(action: { viewModel.showAddCard = true }) {
                    Text("Add new+")
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.cards.isEmpty {
                Text("No cards added yet")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.cards) { card in
                            PaymentCardView(
                                card: card,
                                logoUrl: cardLogos[card.cardType.rawValue],
                                isSelected: false,
                                onSelect: {},
                                onDelete: {
                                    if let cardId = card.id {
                                        Task {
                                            await viewModel.deleteCard(id: cardId)
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
