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
                        .textContentType(.creditCardNumber)
                        .disabled(viewModel.isAddingCard)
                        .onChange(of: viewModel.formattedCardNumber) { newValue in
                            viewModel.formatCardNumber(newValue)
                        }
                    
                    TextField("Cardholder Name", text: $viewModel.cardholderName)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                        .disabled(viewModel.isAddingCard)
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
                        .disabled(viewModel.isAddingCard)
                        .onChange(of: viewModel.expiryDate) { newValue in
                            viewModel.formatExpiryDate(newValue)
                        }
                    
                    TextField("CVV", text: $viewModel.cvv)
                        .keyboardType(.numberPad)
                        .textContentType(.creditCardNumber)
                        .disabled(viewModel.isAddingCard)
                        .onChange(of: viewModel.cvv) { newValue in
                            viewModel.formatCVV(newValue)
                        }
                }
                
                Section {
                    Button(action: {
                        Task {
                            await viewModel.addCard()
                        }
                    }) {
                        if viewModel.isAddingCard {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Spacer()
                            }
                        } else {
                            Text("Add Card")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isAddingCard)
                }
            }
            .navigationTitle("Add New Card")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if !viewModel.isAddingCard {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                    .disabled(viewModel.isAddingCard)
                }
            }
            .alert("Invalid Card", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .onChange(of: viewModel.cardAddedSuccessfully) { success in
                if success {
                    dismiss()
                }
            }
        }
    }
} 
