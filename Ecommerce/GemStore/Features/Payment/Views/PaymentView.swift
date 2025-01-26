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
                            PaymentCardView(card: card, logoUrl: cardLogos[card.cardType.rawValue]) {
                                if let cardId = card.id {
                                    Task {
                                        await viewModel.deleteCard(id: cardId)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct PaymentCardView: View {
    let card: PaymentCard
    let logoUrl: String?
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                if let logoUrl = logoUrl {
                    CachedAsyncImage(url: logoUrl, width: 60)
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            
            Text(card.cardNumber)
                .font(.system(.title3, design: .monospaced))
                .foregroundColor(.white)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("CARDHOLDER NAME")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                    Text(card.cardholderName)
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("VALID THRU")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                    Text(card.expiryDate)
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .frame(width: 300, height: 180)
        .background(
            LinearGradient(
                colors: [.blue, .blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

struct PaymentMethodButton: View {
    let image: String
    
    var body: some View {
        Button(action: {}) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 30)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
        }
    }
}
