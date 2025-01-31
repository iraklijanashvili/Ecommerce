//
//  CheckoutView.swift
//  Ecommerce
//
//  Created by Imac on 24.01.25.
//

import SwiftUI
import Combine

struct CheckoutView: View {
    @StateObject private var viewModel = CheckoutViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    addressSection
                        .padding(.horizontal)
                    
                    NavigationLink(destination: CheckoutPaymentView(
                        productPrice: viewModel.cartService.totalPrice,
                        shippingPrice: viewModel.selectedShippingMethod?.price ?? 0,
                        productName: viewModel.cartService.items.first?.product.name ?? "Unknown Product"
                    )) {
                        Text("Continue to payment")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.black)
                            .cornerRadius(25)
                    }
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
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
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
            
            Text("Checkout")
                .font(.headline)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private var addressSection: some View {
        VStack(spacing: 24) {
            progressIndicator
                .padding(.horizontal)
            
            shippingForm
                .padding(.horizontal)
            
            shippingMethods
                .padding(.horizontal)
            
            totalSection
                .padding(.horizontal)
        }
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 0) {
            StepIndicator(icon: "mappin.circle.fill", isActive: true)
            Line()
                .foregroundColor(.gray.opacity(0.3))
            StepIndicator(icon: "creditcard", isActive: false)
            Line()
                .foregroundColor(.gray.opacity(0.3))
            StepIndicator(icon: "checkmark.circle", isActive: false)
        }
    }
    
    private var shippingForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("STEP 1")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("Shipping")
                .font(.title2)
                .bold()
            
            VStack(spacing: 16) {
                CustomTextField(
                    title: "First name",
                    text: .constant(viewModel.firstName),
                    isEnabled: false,
                    isRequired: true,
                    error: viewModel.formErrors["firstName"]
                )
                CustomTextField(
                    title: "Last name",
                    text: .constant(viewModel.lastName),
                    isEnabled: false,
                    isRequired: true,
                    error: viewModel.formErrors["lastName"]
                )
                
                Menu {
                    ForEach(viewModel.countries, id: \.self) { country in
                        Button(country) {
                            viewModel.selectedCountry = country
                        }
                    }
                } label: {
                    CustomTextField(
                        title: "Country",
                        text: .constant(viewModel.selectedCountry),
                        isEnabled: false,
                        rightIcon: "chevron.down",
                        isRequired: true
                    )
                }
                
                CustomTextField(
                    title: "Street name",
                    text: $viewModel.streetName,
                    isRequired: true,
                    error: viewModel.formErrors["streetName"]
                )
                CustomTextField(
                    title: "City",
                    text: $viewModel.city,
                    isRequired: true,
                    error: viewModel.formErrors["city"]
                )
                CustomTextField(
                    title: "Zip-code",
                    text: $viewModel.zipCode,
                    isRequired: true,
                    error: viewModel.formErrors["zipCode"]
                )
                    .keyboardType(.numberPad)
                CustomTextField(
                    title: "Phone number",
                    text: $viewModel.phoneNumber,
                    isRequired: true,
                    error: viewModel.formErrors["phoneNumber"]
                )
                    .keyboardType(.phonePad)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .alert("Missing Information", isPresented: $viewModel.showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please fill in all required fields")
        }
    }
    
    private var shippingMethods: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shipping method")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(viewModel.shippingMethods) { method in
                    ShippingMethodRow(
                        method: method,
                        isSelected: viewModel.selectedShippingMethod?.id == method.id,
                        action: { viewModel.selectedShippingMethod = method }
                    )
                }
            }
        }
    }
    
    private var totalSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Subtotal")
                    .foregroundColor(.gray)
                Spacer()
                Text("$\(Int(viewModel.cartService.totalPrice))")
                    .bold()
            }
            
            HStack {
                Text("Shipping")
                    .foregroundColor(.gray)
                Spacer()
                Text("$\(Int(viewModel.selectedShippingMethod?.price ?? 0))")
                    .bold()
            }
            
            Divider()
            
            HStack {
                Text("Total")
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
}


struct ShippingMethodRow: View {
    let method: ShippingMethod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(method.title)
                            .font(.headline)
                        Text(method.description)
                            .foregroundColor(.gray)
                    }
                    
                    Text(method.deliveryTime)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if method.price > 0 {
                    Text("$\(Int(method.price))")
                        .font(.headline)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 
