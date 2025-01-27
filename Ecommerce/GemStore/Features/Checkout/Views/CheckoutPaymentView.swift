import SwiftUI

struct CheckoutPaymentView: View {
    @StateObject private var viewModel: CheckoutPaymentViewModel
    @Environment(\.dismiss) private var dismiss
    let onPlaceOrder: () -> Void
    
    init(subtotal: Double, shipping: String, onPlaceOrder: @escaping () -> Void) {
        let vm = CheckoutPaymentViewModel()
        vm.subtotal = subtotal
        vm.shipping = shipping
        _viewModel = StateObject(wrappedValue: vm)
        self.onPlaceOrder = onPlaceOrder
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack(spacing: 20) {
                Image(systemName: "mappin.circle.fill")
                Rectangle()
                    .frame(height: 1)
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.black)
                Rectangle()
                    .frame(height: 1)
                Image(systemName: "checkmark.circle")
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Step indicator
                    Text("STEP 2")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Payment title
                    Text("Payment")
                        .font(.title)
                        .bold()
                    
                    // Payment methods
                    HStack(spacing: 16) {
                        PaymentMethodButton(
                            isSelected: viewModel.selectedPaymentMethod == .cash,
                            icon: "dollarsign.circle",
                            title: "Cash",
                            action: { viewModel.selectedPaymentMethod = .cash }
                        )
                        
                        PaymentMethodButton(
                            isSelected: viewModel.selectedPaymentMethod == .creditCard,
                            icon: "creditcard",
                            title: "Credit Card",
                            action: { viewModel.selectedPaymentMethod = .creditCard }
                        )
                    }
                    
                    if viewModel.selectedPaymentMethod == .creditCard {
                        // Cards section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Choose your card")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(action: { viewModel.showAddCard = true }) {
                                    Text("Add new+")
                                        .foregroundColor(.red)
                                }
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(viewModel.cards) { card in
                                            PaymentCardView(
                                                card: card,
                                                logoUrl: nil,
                                                isSelected: viewModel.selectedCard?.id == card.id,
                                                onSelect: { viewModel.selectedCard = card }
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Order summary
                    VStack(spacing: 16) {
                        HStack {
                            Text("Product price")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("$\(String(format: "%.2f", viewModel.subtotal))")
                        }
                        
                        HStack {
                            Text("Shipping")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(viewModel.shipping)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Subtotal")
                                .bold()
                            Spacer()
                            Text("$\(String(format: "%.2f", viewModel.total))")
                                .bold()
                        }
                    }
                    .padding(.top)
                    
                    // Place order button
                    Button(action: {
                        Task {
                            if await viewModel.placeOrder() {
                                onPlaceOrder()
                            }
                        }
                    }) {
                        Text("Place my order")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(30)
                    }
                    .padding(.top, 32)
                }
                .padding()
            }
        }
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
    }
}

struct PaymentMethodButton: View {
    let isSelected: Bool
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.black : Color.white)
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct PaymentCardView: View {
    let card: PaymentCard
    let logoUrl: String?
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    if let logoUrl = logoUrl {
                        CachedAsyncImage(url: logoUrl, width: 60)
                    }
                    Spacer()
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
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: isSelected ? 2 : 0)
            )
            .cornerRadius(16)
        }
    }
} 