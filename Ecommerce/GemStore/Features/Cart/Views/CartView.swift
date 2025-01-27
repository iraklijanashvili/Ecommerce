//
//  CartView.swift
//  Ecommerce
//
//  Created by Imac on 24.01.25.
//


import SwiftUI

struct CartView: View {
    @StateObject private var viewModel: CartViewModel = CartViewModel()
    @State private var showingCheckout = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    cartItemsSection
                    
                    priceBreakdownSection
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("Total")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text(viewModel.totalPrice, format: .currency(code: "USD"))
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        NavigationLink(destination: CheckoutView()) {
                            Text("Continue to payment")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(viewModel.items.isEmpty ? Color.gray : Color.black)
                                .cornerRadius(25)
                        }
                        .disabled(viewModel.items.isEmpty)
                    }
                    .padding()
                    .background(Color.white)
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
    }
    
    private var cartItemsSection: some View {
        VStack {
            if viewModel.items.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "cart.badge.minus")
                        .font(.system(size: 70))
                        .foregroundColor(.gray)
                    
                    Text("Your cart is empty")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("Items you add to your cart will appear here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                VStack(spacing: 20) {
                    ForEach(viewModel.items) { item in
                        CartItemView(item: item) { quantity in
                            viewModel.updateQuantity(itemId: item.id, quantity: quantity)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var priceBreakdownSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Product price")
                    .foregroundColor(.gray)
                Spacer()
                Text("$\(Int(viewModel.totalPrice))")
                    .bold()
            }
            
            HStack {
                Text("Shipping")
                    .foregroundColor(.gray)
                Spacer()
                Text(viewModel.shipping)
                    .bold()
            }
            
            HStack {
                Text("Subtotal")
                    .foregroundColor(.gray)
                Spacer()
                Text("$\(Int(viewModel.totalPrice))")
                    .bold()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var navigationBar: some View {
        Text("Cart")
    }
}

struct CartItemView: View {
    let item: CartItem
    let onQuantityChange: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: item.product.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 120, height: 120)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.product.name)
                    .font(.headline)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("$\(Int(item.product.price))")
                    .font(.title3)
                    .bold()
                
                Text("Size: \(item.selectedSize) | Color: \(item.selectedColor.rawValue.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                HStack(spacing: 16) {
                    Button(action: {
                        onQuantityChange(item.quantity - 1)
                    }) {
                        Image(systemName: "minus")
                            .foregroundColor(.black)
                            .frame(width: 32, height: 32)
                    }
                    
                    Text("\(item.quantity)")
                        .frame(width: 30)
                        .font(.headline)
                    
                    Button(action: {
                        onQuantityChange(item.quantity + 1)
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                            .frame(width: 32, height: 32)
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding(.vertical, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
} 
