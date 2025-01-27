//
//  CheckoutPaymentView.swift
//  Ecommerce
//
//  Created by Imac on 24.01.25.
//

import SwiftUI
import FirebaseFirestore

struct CheckoutPaymentView: View {
    @StateObject private var viewModel: CheckoutPaymentViewModel
    @StateObject private var paymentViewModel = PaymentViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var cardLogos: [String: String] = [:]
    @State private var showAddCard = false
    @State private var showOrderCompleted = false
    
    init(productPrice: Double, shippingPrice: Double = 0) {
        _viewModel = StateObject(wrappedValue: CheckoutPaymentViewModel(
            productPrice: productPrice,
            shippingPrice: shippingPrice
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    progressIndicator
                        .padding(.horizontal)
                    
                    paymentMethodsSection
                        .padding(.horizontal)
                    
                    priceBreakdownSection
                        .padding(.horizontal)
                    
                    placeOrderButton
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                .padding(.vertical)
            }
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .top) {
            navigationBar
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchCardLogos()
            Task {
                await viewModel.loadCards()
            }
        }
        .sheet(isPresented: $showAddCard) {
            AddCardView(parentViewModel: paymentViewModel)
        }
        .onChange(of: paymentViewModel.cards) { newCards in
            Task {
                await viewModel.loadCards()
            }
        }
        .fullScreenCover(isPresented: $showOrderCompleted) {
            OrderCompletedView(navigationDelegate: self)
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
    
    private var navigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
                    .imageScale(.large)
            }
            
            Spacer()
            
            Text("Check out")
                .font(.headline)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 0) {
            StepIndicator(icon: "mappin.circle.fill", isActive: false)
            Line()
                .foregroundColor(.gray.opacity(0.3))
            StepIndicator(icon: "creditcard", isActive: true)
            Line()
                .foregroundColor(.gray.opacity(0.3))
            StepIndicator(icon: "checkmark.circle", isActive: false)
        }
    }
    
    private var paymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("STEP 2")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("Payment")
                .font(.title2)
                .bold()
            
            HStack(spacing: 12) {
                PaymentMethodButton(
                    isSelected: viewModel.selectedPaymentMethod == .cash,
                    icon: "dollarsign.circle.fill",
                    title: "Cash",
                    action: { viewModel.selectedPaymentMethod = .cash }
                )
                
                PaymentMethodButton(
                    isSelected: viewModel.selectedPaymentMethod == .creditCard,
                    icon: "creditcard.fill",
                    title: "Credit Card",
                    action: { viewModel.selectedPaymentMethod = .creditCard }
                )
            }
            
            if viewModel.selectedPaymentMethod == .creditCard {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if viewModel.cards.isEmpty {
                    VStack(spacing: 16) {
                        Text("No cards added yet")
                            .foregroundColor(.gray)
                        
                        Button(action: { showAddCard = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add new card")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.cards) { card in
                                    PaymentCardView(
                                        card: card,
                                        logoUrl: cardLogos[card.cardType.rawValue],
                                        isSelected: viewModel.selectedCard?.id == card.id,
                                        onSelect: { viewModel.selectedCard = card }
                                    )
                                }
                            }
                        }
                        
                        Button(action: { showAddCard = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add another card")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
    
    private var priceBreakdownSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Product price")
                    .foregroundColor(.gray)
                Spacer()
                Text("$\(Int(viewModel.productPrice))")
                    .bold()
            }
            
            HStack {
                Text("Shipping")
                    .foregroundColor(.gray)
                Spacer()
                if viewModel.shippingPrice == 0 {
                    Text("Freeship")
                        .bold()
                } else {
                    Text("$\(Int(viewModel.shippingPrice))")
                        .bold()
                }
            }
            
            Divider()
            
            HStack {
                Text("Subtotal")
                    .font(.headline)
                Spacer()
                Text("$\(Int(viewModel.totalAmount))")
                    .font(.headline)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var placeOrderButton: some View {
        Button(action: {
            Task {
                if await viewModel.placeOrder() {
                    showOrderCompleted = true
                }
            }
        }) {
            Text("Place my order")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.canPlaceOrder ? Color.black : Color.gray)
                .cornerRadius(25)
        }
        .disabled(!viewModel.canPlaceOrder)
        .padding(.top, 8)
    }
}

extension CheckoutPaymentView: OrderCompletionNavigationDelegate {
    func navigateToMyOrders() {
    }
    
    func navigateToHome() {
        dismiss()
    }
}
