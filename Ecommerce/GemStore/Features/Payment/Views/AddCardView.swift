//
//  AddCardView.swift
//  Ecommerce
//
//  Created by Imac on 26.01.25.
//

import SwiftUI
import Combine

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddCardViewModel
    
    init(parentViewModel: PaymentViewModel) {
        _viewModel = StateObject(wrappedValue: AddCardViewModel(parentViewModel: parentViewModel))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Card Number", text: $viewModel.formattedCardNumber)
                        .keyboardType(.numberPad)
                        .onChange(of: viewModel.formattedCardNumber) { newValue in
                            viewModel.formatCardNumber(newValue)
                        }
                    
                    TextField("Cardholder Name", text: $viewModel.cardholderName)
                        .textInputAutocapitalization(.words)
                        .onChange(of: viewModel.cardholderName) { newValue in
                            if newValue.count > 50 {
                                viewModel.cardholderName = String(newValue.prefix(50))
                            }
                        }
                        .onSubmit {
                            viewModel.cardholderName = viewModel.cardholderName
                                .components(separatedBy: .whitespaces)
                                .filter { !$0.isEmpty }
                                .joined(separator: " ")
                        }
                    
                    TextField("MM/YY", text: $viewModel.expiryDate)
                        .keyboardType(.numberPad)
                        .onChange(of: viewModel.expiryDate) { newValue in
                            viewModel.formatExpiryDate(newValue)
                        }
                    
                    TextField("CVV", text: $viewModel.cvv)
                        .keyboardType(.numberPad)
                        .onChange(of: viewModel.cvv) { newValue in
                            viewModel.formatCVV(newValue)
                        }
                }
                
                Section {
                    Button("Add Card") {
                        if viewModel.validateCard() {
                            Task {
                                await viewModel.addCard()
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
            .navigationTitle("Add New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Invalid Card", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
} 
