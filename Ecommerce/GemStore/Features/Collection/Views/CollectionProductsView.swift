//
//  CollectionProductsView.swift
//  Ecommerce
//
//  Created by Imac on 22.01.25.
//

import SwiftUI

struct CollectionProductsView: View {
    let collectionType: String
    let title: String
    let isFromHomePage: Bool
    @StateObject private var viewModel = CollectionProductsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                SharedErrorView(error: error) {
                    Task {
                        await viewModel.fetchProducts(forCollection: collectionType)
                    }
                }
            } else {
                if viewModel.products.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No products found")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(viewModel.products) { product in
                            NavigationLink(destination: SharedProductDetailView(product: product, isFromHomePage: isFromHomePage)) {
                                SharedProductCard(product: product)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            if !isFromHomePage {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchProducts(forCollection: collectionType)
            }
        }
    }
}

private struct CollectionErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Error: \(error.localizedDescription)")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Retry") {
                retryAction()
            }
        }
    }
}

private struct CollectionProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: product.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure(_):
                    Color.gray
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 200)
            .clipped()
            
            Text(product.name)
                .font(.subheadline)
                .foregroundColor(.black)
                .lineLimit(2)
                .padding(.horizontal, 8)
            
            Text(product.formattedPrice)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct CollectionProductDetailView: View {
    let product: Product
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: product.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Color.gray
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxHeight: 400)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(product.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text(product.formattedPrice)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
} 
