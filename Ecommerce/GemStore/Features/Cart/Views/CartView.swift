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
                            
                            Text("$\(Int(viewModel.totalPrice))")
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
                EmptyCartView()
            } else {
                VStack(spacing: 20) {
                    ForEach(viewModel.items) { item in
                        CartItemView(
                            item: item,
                            updateHandler: viewModel
                        )
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
        HStack {
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
                    .imageScale(.large)
            }
            .opacity(0)
            
            Spacer()
            
            Text("Cart")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
                    .imageScale(.large)
            }
            .opacity(0)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

private struct EmptyCartView: View {
    var body: some View {
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
    }
}

private struct CartItemView: View {
    @StateObject private var viewModel: CartItemViewModel
    
    init(item: CartItem, updateHandler: CartItemUpdateHandler) {
        _viewModel = StateObject(wrappedValue: CartItemViewModel(
            item: item,
            updateHandler: updateHandler
        ))
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            productImage
            
            VStack(alignment: .leading, spacing: 4) {
                productInfo
                quantityControls
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var productImage: some View {
        AsyncImage(url: URL(string: viewModel.item.product.defaultImageUrl)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 80, height: 80)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            case .failure:
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .frame(width: 80, height: 80)
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 80, height: 80)
    }
    
    private var productInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.item.product.name)
                .font(.headline)
                .lineLimit(2)
            
            Text(String(format: "$%.2f", viewModel.totalPrice))
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
    
    private var quantityControls: some View {
        HStack(spacing: 16) {
            Button(action: viewModel.decrementQuantity) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.black)
            }
            .disabled(viewModel.isUpdating)
            
            Text("\(viewModel.quantity)")
                .font(.headline)
            
            Button(action: viewModel.incrementQuantity) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.black)
            }
            .disabled(viewModel.isUpdating)
            
            Spacer()
            
            Button(action: viewModel.removeItem) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .disabled(viewModel.isUpdating)
        }
        .padding(.top, 8)
    }
} 
